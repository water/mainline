# encoding: utf-8
module MessagesHelper
  def sender_and_recipient_display(message)
    sender_and_recipient_for(message).collect(&:capitalize).join(",")
  end

  def sender_and_recipient_for(message)
    if message.recipient == current_user
      [link_to(h(message.sender_name), message.sender), "me"]
    else
      ["me", link_to(h(message.recipient.title), message.recipient)]
    end
  end

  def other_party(message,user)
    message.recipient == user ? message.sender : message.recipient
  end

  def message_title(message)
    sender, recipient = sender_and_recipient_for(message)

    case message.notifiable
    when MergeRequest
      msg_link = link_to('merge request', [message.notifiable.target_repository.project,
                                           message.notifiable.target_repository,
                                           message.notifiable])
      "From <strong>#{sender}</strong> to <strong>#{recipient}</strong>, about a #{msg_link}"
    when Membership
      %Q{<strong>#{sender}</strong> added <strong>#{recipient}</strong> to the } +
        %Q{team #{link_to("#{message.notifiable.group.name}", message.notifiable.group)}}
    when Committership
      committership = message.notifiable
      user_link = link_to(committership.committer.title, [committership.repository.project,
                                                          committership.repository,
                                                          :committerships])
      %Q{<strong>#{sender}</strong> added #{user_link} as committer in } +
        %Q{<strong>#{committership.repository.name}</strong>}
    else
      "#{link_to('message', message)} from <strong>#{sender}</strong> to <strong>#{recipient}</strong>"
    end
  end

  def sender_avatar(message)
    if message.replies_enabled?
      avatar_from_email(message.sender.email, :size => 32)
    else
      image_tag("default_face.gif", :size => "32x32")
    end
  end
end
