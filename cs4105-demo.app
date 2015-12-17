application assignmentdemo

imports mdl


section user interface

template main(){
  mdlHead( "indigo", "pink" )
  fixedHeader(
    "Messaging App",
    [ ( navigate(createUser()), "Create User" )
     ,( navigate(account()), "Account" )
     ,( navigate(admin()), "Admin" )
    ]
  ){
    elements
  }
}

page root(){
  main{
    grid{
      card("Messages"){
        showMessages( from Message as m order by m.created desc limit 50 )
        if( loggedIn() ){
          createMessage
        }
      }
    }
  }
}

template showMessages( mlist: [Message] ){
  messagelistStyle{
    placeholder "messagesph"{
      for( m in mlist order by m.created ){
        div[ class="author" ]{ output( m.author.name ) }
        output( m.text )
      }
      scrollToBottomOfId( "messagelist" )
    }
  }
  refreshPlaceholderInterval( "messagesph", 1000 )
}

template createMessage(){
  var m := Message{}
  var message := ""
  form{
    grid{
      cell( 12 ){
        input( "Message", message )[ autofocus="", class="in1", autocomplete="off" ]
      }
      cell( 12 ){
        submit action{
          m.text := message;
          m.author := securityContext.principal;
          m.save();
          replace("messagesph");
          runscript("$('.in1').val('')");
        } [ajax] { "Send Message" }
      }
    }
  }
}

page createUser(){
  var u := User{}
  maingridcard( "Create Account" ){
    form{
      grid{
        cell( 12 ){ input( "Name", u.name ) }
        cell( 12 ){ input( "Password", u.password ) }
        cell( 12 ){
          submit action{
            if( (select count(*) from User) == 0 ){
              u.admin := true;
            }
            u.password := u.password.digest();
            u.save();
            securityContext.principal := u;
            return root();
          }{ "Create" }
        }
      }
    }
  }
}

page account(){
  main{
    grid{
      if( ! loggedIn() ){
        card( "Login" ){
          logintemplate
        }
      }
      else{
        card( "Logout" ){
          logout
        }
      }
    }
  }
}

override page accessDenied(){
  maingridcard( "Access Denied" ){
    title{ "Access Denied" }
    navigate root() { "Return To Home Page" }
  }
}

page user( u: User ){
  maingridcard("User page for " + u.name){
    showMessages( from Message as m where m.author = ~u order by m.created )
  }
}

page admin(){
  maingridcard( "Admin" ){
    submit action{
      for( m: Message ){
        m.delete();
      }
      securityContext.principal.lastReset := now();
      return root();
    }{ "Delete All Messages" }
  }
}


section data model

entity Message{
  author: User
  text: WikiText
}

entity User{
  name: String (id)
  password: Secret ( validate(password.length() >= 10, "Minimum password length is 10." ) )
  admin: Bool
  lastReset: DateTime
}


section access control

principal is User with credentials name, password

access control rules

rule page root(){ true }
rule page createUser(){ true }
rule page account(){ true }
rule page user( u: User ){ u == principal }
rule page admin(){ principal.admin }


section override default authentication for styling

template logintemplate() {
  var name: String
  var pass: Secret
  var stayLoggedIn := false
  form {
    grid{
      cell(12){ input( "Name", name ) }
      cell(12){ input( "Password", pass ) }
      cell(12){ input( "Stay logged in", stayLoggedIn )}
      cell(12){ submit signinAction() { "Login" } }
    }
  }
  action signinAction() {
    validate( authenticate(name,pass), "The login credentials are not valid." );
    getSessionManager().stayLoggedIn := stayLoggedIn;
    return root();
  }
}

override template logout() {
  "Logged in as: " output( securityContext.principal.name )
  form{
    submit action{ logout(); }{ "Logout" }
  }
}


section utils

template refreshPlaceholderInterval( ph: String, time: Int ){
  submitlink action{
    replace(ph);
  }[ id="refresh", style="display:none;", no loading feedback ]{ "refresh" }
  <script>
    setInterval( function(){ $('#refresh').click(); }, ~time );
  </script>
}

template scrollToBottomOfId(elemid: String){
  <script>
    setTimeout( function(){ document.getElementById('~elemid').scrollTop = 9999999; }, 100 );
  </script>
}

template messagelistStyle(){
  <style>
    #messagelist {
      position: absolute;
      width: auto!important;
      height: auto!important;
      top: 0;
      bottom: 60px;
      left: 0;
      right: 0;
      overflow: scroll;
    }
    .author {
    font-weight: bold;
    }
  </style>
  div[ style="position:relative;height:400px;" ]{
    div[ id="messagelist" ]{
      elements
    }
  }
}
