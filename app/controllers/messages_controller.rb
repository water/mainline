# encoding: utf-8
#--
#   Copyright (C) 2009 Nokia Corporation and/or its subsidiary(-ies)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++
class MessagesController < ApplicationController
  before_filter :login_required
  before_filter :ssl_required
  renders_in_global_context
  
  def index
    @messages = current_user.messages_in_inbox(100, params[:page])
    @root = Breadcrumb::ReceivedMessages.new(current_user)
    respond_to do |wants|
      wants.html
      wants.xml {render :xml => @messages}
    end
  end
  
  def all
    @messages = current_user.top_level_messages.page(params[:page])
    @root = Breadcrumb::AllMessages.new(current_user)
  end
  
  def sent
    @messages = current_user.
      sent_messages.
      page(params[:page]).
      all
      
    @root = Breadcrumb::SentMessages.new(current_user)
  end
  
  def read
    @message = current_user.received_messages.find(params[:id])
    @message.read
    respond_to do |wants|
      wants.js { head :ok }
    end
  end

  def bulk_update
    message_ids = params[:message_ids].to_a
    message_ids.each do |message_id|
      # if message = current_user.all_messages.find(message_id)
      if message = Message.find(:first, :conditions => ['(recipient_id=? OR sender_id=?) AND id=?', current_user, current_user, message_id])
        if params[:requested_action] == 'archive'
          message.archived_by(current_user)
          message.save!
        else
          logger.info("Marking message #{message_id} as read")
          message.read
        end
      end
    end
    redirect_to :action => :index
  end

  
  def show
    @message = Message.find(params[:id])
    if !@message.readable_by?(current_user)
      raise ActiveRecord::RecordNotFound and return
    end
    @message.mark_thread_as_read_by_user(current_user)
    respond_to do |wants|
      wants.html
      wants.xml {render :xml => @message}
      wants.js {render :partial => "message", :layout => false}
    end
  end
  

  def create
    require "colorize"
    
    puts params.inspect.red
    
    @messages = MessageThread.new(params[:message].merge({
      recipients: (params[:message] || {})[:recipients], 
      sender: current_user
    }))
    
    if @messages.save
      flash[:notice] =  "#{@messages.title} sent"
      redirect_to :action => :index
    else
      @message = @messages.message
      render :action => :new
    end
  end
  
  def new
    @message = current_user.sent_messages.new(:recipients => params[:to])
  end
  
  # POST /messages/<id>/reply
  def reply
    original_message = current_user.received_messages.find(params[:id])
    @message = original_message.build_reply(params[:message])
    original_message.read! unless original_message.read?
    if @message.save
      flash[:notice] = "Your reply was sent"
      redirect_to :action => :show, :id => original_message
    else
      flash[:error] = "Your message could not be sent"
      redirect_to :action => :index
    end
  end
  
  def auto_complete_for_message_recipients
    @users = User.
      where("LOWER(users.login) LIKE ?", "%#{params[:q].to_s.downcase}%").
      where("users.id != ?", current_user.id).
      limit(10)
    render :text => @users.map(&:login).join("\n")
  end
end
