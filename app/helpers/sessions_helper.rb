# encoding: utf-8

module SessionsHelper

  # determines which form to display for login
  def login_method
    if params[:method]=='openid'
      "<script  type=\"text/javascript\">
         $(document).ready(function(){
           $(\"#regular_login_fields\").toggle();
           $(\"#openid_login_fields\").toggle();
         })
      </script>"
    end
  end

  def switch_login(title, action)
    link_to_function(title, <<-EOS)
    
      $(".foo1").click(
      function() {
        $("body").css("background", "red");
        $("#regular_login_fields").addClass("login_hidden");
        $("#openid_login_fields").removeClass("login_hidden");
      });
      
EOS
  end


    def switch_op_login(title, action)
      link_to_function(title, <<-EOS)

        $(".regular-switch a").click(
        function() {
          $("p.regular-switch").toggle();
          $("#openid_login_fields").addClass("login_hidden");
          $("#regular_login_fields").removeClass("login_hidden");
        });

  EOS
    end
    
end
