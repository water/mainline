# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120617122643) do

  create_table "administrators", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "archived_events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.integer  "action"
    t.string   "data"
    t.text     "body"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "user_email"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "assistant_registered_for_course_has_lab_has_groups", :id => false, :force => true do |t|
    t.integer "assistant_registered_for_course_id"
    t.integer "lab_has_group_id"
  end

  create_table "assistant_registered_for_courses", :force => true do |t|
    t.integer  "given_course_id"
    t.integer  "assistant_id"
    t.boolean  "can_change_deadline"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "assistants", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "modified_at"
    t.text     "body"
    t.string   "ancestry"
  end

  add_index "comments", ["ancestry"], :name => "index_comments_on_ancestry"

  create_table "course_codes", :force => true do |t|
    t.string   "code"
    t.integer  "course_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "department_id"
  end

  create_table "default_deadlines", :force => true do |t|
    t.datetime "at"
    t.integer  "lab_id"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "emails", :force => true do |t|
    t.integer  "user_id"
    t.string   "address"
    t.string   "aasm_state"
    t.string   "confirmation_code"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "emails", ["address"], :name => "index_emails_on_address"
  add_index "emails", ["user_id"], :name => "index_emails_on_user_id"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.integer  "project_id",  :null => false
    t.integer  "action",      :null => false
    t.string   "data"
    t.text     "body"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "user_email"
  end

  add_index "events", ["action"], :name => "index_events_on_action"
  add_index "events", ["created_at", "project_id"], :name => "index_events_on_created_at_and_project_id"
  add_index "events", ["created_at"], :name => "index_events_on_created_at"
  add_index "events", ["project_id"], :name => "index_events_on_project_id"
  add_index "events", ["target_type", "target_id"], :name => "index_events_on_target_type_and_target_id"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "examiners", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "examiners_given_courses", :id => false, :force => true do |t|
    t.integer "examiner_id"
    t.integer "given_course_id"
  end

  create_table "extended_deadlines", :force => true do |t|
    t.datetime "at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "lab_has_group_id"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.string   "watchable_type"
    t.integer  "watchable_id"
    t.string   "action"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.boolean  "notify_by_email", :default => false
  end

  add_index "favorites", ["watchable_type", "watchable_id", "user_id"], :name => "index_favorites_on_watchable_type_and_watchable_id_and_user_id"

  create_table "feed_items", :force => true do |t|
    t.integer  "event_id"
    t.integer  "watcher_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "feed_items", ["watcher_id", "created_at"], :name => "index_feed_items_on_watcher_id_and_created_at"

  create_table "given_courses", :force => true do |t|
    t.integer  "course_id"
    t.integer  "study_period_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "hooks", :force => true do |t|
    t.integer  "user_id"
    t.integer  "repository_id"
    t.string   "url"
    t.string   "last_response"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "failed_request_count",     :default => 0
    t.integer  "successful_request_count", :default => 0
  end

  add_index "hooks", ["repository_id"], :name => "index_hooks_on_repository_id"

  create_table "initial_lab_commit_for_labs", :id => false, :force => true do |t|
    t.integer "initial_lab_commit_id"
    t.integer "lab_id"
  end

  create_table "initial_lab_commits", :force => true do |t|
    t.string   "commit_hash"
    t.integer  "repository_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "lab_deadlines", :force => true do |t|
    t.datetime "at"
    t.integer  "lab_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "lab_descriptions", :force => true do |t|
    t.string   "description"
    t.string   "title"
    t.integer  "study_period_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "lab_groups", :force => true do |t|
    t.integer  "number"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "given_course_id"
  end

  create_table "lab_groups_registered_courses", :id => false, :force => true do |t|
    t.integer "lab_group_id"
    t.integer "registered_course_id"
  end

  create_table "lab_groups_student_registered_for_courses", :id => false, :force => true do |t|
    t.integer "lab_group_id"
    t.integer "student_registered_for_course_id"
  end

  create_table "lab_has_groups", :force => true do |t|
    t.integer  "lab_id"
    t.integer  "lab_group_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "repository_id"
    t.string   "grade"
    t.string   "state"
  end

  create_table "lab_has_registered_assistants", :force => true do |t|
    t.integer  "assistant_registered_for_course_id"
    t.integer  "lab_id"
    t.integer  "when_id"
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  create_table "labs", :force => true do |t|
    t.integer  "number"
    t.integer  "lab_commit_id"
    t.integer  "given_course_id"
    t.integer  "lab_description_id"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "active",             :default => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "subject"
    t.text     "body"
    t.string   "notifiable_type"
    t.integer  "notifiable_id"
    t.string   "aasm_state"
    t.integer  "in_reply_to_id"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.integer  "root_message_id"
    t.boolean  "has_unread_replies",    :default => false
    t.boolean  "archived_by_sender",    :default => false
    t.boolean  "archived_by_recipient", :default => false
    t.datetime "last_activity_at"
  end

  add_index "messages", ["aasm_state"], :name => "index_messages_on_aasm_state"
  add_index "messages", ["in_reply_to_id"], :name => "index_messages_on_in_reply_to_id"
  add_index "messages", ["notifiable_type", "notifiable_id"], :name => "index_messages_on_notifiable_type_and_notifiable_id"
  add_index "messages", ["recipient_id"], :name => "index_messages_on_recipient_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "queue_classic_jobs", :force => true do |t|
    t.string   "q_name"
    t.string   "method"
    t.text     "args"
    t.datetime "locked_at"
  end

  add_index "queue_classic_jobs", ["q_name", "id"], :name => "idx_qc_on_name_only_unlocked"

  create_table "repositories", :force => true do |t|
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.boolean  "ready",       :default => false
    t.string   "hashed_path"
    t.integer  "disk_usage"
  end

  add_index "repositories", ["hashed_path"], :name => "index_repositories_on_hashed_path", :unique => true
  add_index "repositories", ["ready"], :name => "index_repositories_on_ready"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "kind"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "student_registered_for_courses", :force => true do |t|
    t.integer  "student_id"
    t.integer  "given_course_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "students", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "study_periods", :force => true do |t|
    t.integer  "year"
    t.integer  "period"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "submissions", :force => true do |t|
    t.string   "commit_hash"
    t.integer  "lab_has_group_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "comment_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",               :limit => 40
    t.string   "salt",                           :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",                :limit => 40
    t.datetime "activated_at"
    t.integer  "ssh_key_id"
    t.string   "fullname"
    t.text     "url"
    t.text     "identity_url"
    t.boolean  "is_admin",                                     :default => false
    t.datetime "suspended_at"
    t.boolean  "public_email",                                 :default => true
    t.boolean  "wants_email_notifications",                    :default => true
    t.string   "password_key"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "default_favorite_notifications",               :default => false
    t.string   "ssn"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["password_key"], :name => "index_users_on_password_key"
  add_index "users", ["ssh_key_id"], :name => "index_users_on_ssh_key_id"

end
