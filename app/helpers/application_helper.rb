module ApplicationHelper
  def avatar_url(user, size=140)
    #default_url = "#{root_url}images/guest.png"
    #&d=#{CGI.escape(default_url)}
    if(user.email)
      gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
      return("http://gravatar.com/avatar/#{gravatar_id}.png?s=" + size.to_s)
    else
    end
  end

end
