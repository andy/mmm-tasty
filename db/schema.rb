# This file is auto-generated from the current state of the database. Instead of editing this file,
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 78) do

  create_table "attachments", :force => true do |t|
    t.integer "entry_id",     :limit => 11, :default => 0,  :null => false
    t.string  "content_type"
    t.string  "filename",                   :default => "", :null => false
    t.integer "size",         :limit => 11, :default => 0,  :null => false
    t.string  "type"
    t.string  "metadata"
    t.integer "parent_id",    :limit => 11
    t.string  "thumbnail"
    t.integer "width",        :limit => 11
    t.integer "height",       :limit => 11
    t.integer "user_id",      :limit => 11, :default => 0,  :null => false
  end

  add_index "attachments", ["entry_id"], :name => "index_attachments_on_entry_id"
  add_index "attachments", ["parent_id"], :name => "index_attachments_on_parent_id"

  create_table "avatars", :force => true do |t|
    t.integer "user_id",      :limit => 11, :default => 0, :null => false
    t.string  "content_type"
    t.string  "filename"
    t.integer "size",         :limit => 11
    t.integer "position",     :limit => 11
    t.integer "parent_id",    :limit => 11
    t.string  "thumbnail"
    t.integer "width",        :limit => 11
    t.integer "height",       :limit => 11
  end

  add_index "avatars", ["user_id"], :name => "index_avatars_on_user_id"
  add_index "avatars", ["parent_id"], :name => "index_avatars_on_parent_id"

  create_table "bookmarklets", :force => true do |t|
    t.integer  "user_id",    :limit => 11,                        :null => false
    t.datetime "created_at",                                      :null => false
    t.string   "name",                                            :null => false
    t.string   "entry_type", :limit => 16, :default => "text",    :null => false
    t.text     "tags"
    t.string   "visibility", :limit => 16, :default => "private", :null => false
    t.boolean  "autosave",                 :default => false,     :null => false
    t.boolean  "is_public",                :default => false,     :null => false
  end

  add_index "bookmarklets", ["user_id", "created_at"], :name => "index_bookmarklets_on_user_id_and_created_at"
  add_index "bookmarklets", ["is_public", "created_at"], :name => "index_bookmarklets_on_is_public_and_created_at"

  create_table "comment_views", :force => true do |t|
    t.integer "entry_id",            :limit => 11, :default => 0, :null => false
    t.integer "user_id",             :limit => 11, :default => 0, :null => false
    t.integer "last_comment_viewed", :limit => 11, :default => 0, :null => false
  end

  add_index "comment_views", ["entry_id", "user_id"], :name => "index_comment_views_on_entry_id_and_user_id", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "entry_id",     :limit => 11, :default => 0,     :null => false
    t.text     "comment"
    t.integer  "user_id",      :limit => 11, :default => 0
    t.string   "ext_username"
    t.string   "ext_url"
    t.boolean  "is_disabled",                :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at"
    t.text     "comment_html"
    t.string   "remote_ip",    :limit => 17
  end

  add_index "comments", ["entry_id", "user_id"], :name => "index_comments_on_entry_id_and_user_id"

  create_table "entries", :force => true do |t|
    t.integer  "user_id",          :limit => 11, :default => 0,     :null => false
    t.text     "data_part_1"
    t.text     "data_part_2"
    t.text     "data_part_3"
    t.string   "type",                           :default => "",    :null => false
    t.boolean  "is_disabled",                    :default => false, :null => false
    t.datetime "created_at",                                        :null => false
    t.text     "metadata"
    t.integer  "comments_count",   :limit => 11, :default => 0,     :null => false
    t.datetime "updated_at"
    t.boolean  "is_voteable",                    :default => false
    t.boolean  "is_private",                     :default => false, :null => false
    t.text     "cached_tag_list"
    t.boolean  "is_mainpageable",                :default => true,  :null => false
    t.boolean  "comments_enabled",               :default => false, :null => false
  end

  add_index "entries", ["user_id", "created_at", "type"], :name => "index_entries_on_user_id_and_created_at_and_type"
  add_index "entries", ["is_mainpageable", "created_at", "type"], :name => "index_entries_on_is_mainpageable_and_created_at_and_type"
  add_index "entries", ["user_id", "is_private", "created_at"], :name => "index_entries_on_user_id_and_is_private_and_created_at"
  add_index "entries", ["user_id", "is_private", "id"], :name => "tmpindex"
  add_index "entries", ["id", "user_id", "is_private"], :name => "tmpindex2"
  add_index "entries", ["is_mainpageable", "is_private", "id"], :name => "index_entries_on_is_mainpageable_and_is_private_and_id"

  create_table "entry_ratings", :force => true do |t|
    t.integer  "entry_id",   :limit => 11, :default => 0,  :null => false
    t.string   "entry_type", :limit => 20, :default => "", :null => false
    t.datetime "created_at",                               :null => false
    t.integer  "user_id",    :limit => 11, :default => 0,  :null => false
    t.integer  "value",      :limit => 11, :default => 0,  :null => false
  end

  add_index "entry_ratings", ["entry_id"], :name => "index_entry_ratings_on_entry_id", :unique => true
  add_index "entry_ratings", ["value", "entry_type"], :name => "index_entry_ratings_on_value_and_entry_type"

  create_table "entry_subscribers", :id => false, :force => true do |t|
    t.integer "entry_id", :limit => 11, :default => 0, :null => false
    t.integer "user_id",  :limit => 11, :default => 0, :null => false
  end

  add_index "entry_subscribers", ["entry_id", "user_id"], :name => "index_entry_subscribers_on_entry_id_and_user_id", :unique => true

  create_table "entry_votes", :force => true do |t|
    t.integer "entry_id", :limit => 11, :default => 0, :null => false
    t.integer "user_id",  :limit => 11, :default => 0, :null => false
    t.integer "value",    :limit => 11, :default => 0, :null => false
  end

  add_index "entry_votes", ["entry_id", "user_id"], :name => "index_entry_votes_on_entry_id_and_user_id", :unique => true

  create_table "faves", :force => true do |t|
    t.integer  "user_id",       :limit => 11, :null => false
    t.integer  "entry_id",      :limit => 11, :null => false
    t.string   "entry_type",    :limit => 64, :null => false
    t.integer  "entry_user_id", :limit => 11, :null => false
    t.datetime "created_at"
  end

  add_index "faves", ["user_id", "entry_id"], :name => "index_faves_on_user_id_and_entry_id", :unique => true
  add_index "faves", ["user_id", "entry_user_id"], :name => "index_faves_on_user_id_and_entry_user_id"
  add_index "faves", ["user_id", "entry_type"], :name => "index_faves_on_user_id_and_entry_type"

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id",      :limit => 11,                    :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.text     "message",                                       :null => false
    t.boolean  "is_public",                  :default => false, :null => false
    t.boolean  "is_moderated",               :default => false, :null => false
  end

  add_index "feedbacks", ["user_id"], :name => "index_feedbacks_on_user_id", :unique => true
  add_index "feedbacks", ["is_public", "created_at"], :name => "index_feedbacks_on_is_public_and_created_at"
  add_index "feedbacks", ["is_moderated", "created_at"], :name => "index_feedbacks_on_is_moderated_and_created_at"

  create_table "helps", :force => true do |t|
    t.string   "path",                      :default => "", :null => false
    t.text     "body"
    t.integer  "impressions", :limit => 11, :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "innodb_table_monitor", :id => false, :force => true do |t|
    t.integer "x", :limit => 11
  end

  create_table "messages", :force => true do |t|
    t.integer  "user_id",     :limit => 11, :default => 0,     :null => false
    t.integer  "sender_id",   :limit => 11, :default => 0,     :null => false
    t.text     "body",                                         :null => false
    t.text     "body_html"
    t.boolean  "is_private",                :default => false, :null => false
    t.boolean  "is_disabled",               :default => false, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at"
  end

  add_index "messages", ["user_id"], :name => "index_messages_on_user_id"

  create_table "mobile_settings", :force => true do |t|
    t.integer  "user_id",    :limit => 11, :default => 0,  :null => false
    t.string   "keyword",                  :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mobile_settings", ["user_id"], :name => "index_mobile_settings_on_user_id", :unique => true
  add_index "mobile_settings", ["keyword"], :name => "index_mobile_settings_on_keyword", :unique => true

  create_table "performances", :force => true do |t|
    t.string  "controller",                                :null => false
    t.string  "action",                                    :null => false
    t.integer "calls",      :limit => 11, :default => 0,   :null => false
    t.float   "realtime"
    t.date    "day",                                       :null => false
    t.float   "stime",                    :default => 0.0, :null => false
    t.float   "utime",                    :default => 0.0, :null => false
    t.float   "cstime",                   :default => 0.0, :null => false
    t.float   "cutime",                   :default => 0.0, :null => false
  end

  add_index "performances", ["controller", "action", "day"], :name => "index_performances_on_controller_and_action_and_day", :unique => true

  create_table "relationships", :force => true do |t|
    t.integer  "user_id",                   :limit => 11,  :default => 0, :null => false
    t.integer  "reader_id",                 :limit => 11,  :default => 0, :null => false
    t.integer  "position",                  :limit => 11
    t.integer  "read_count",                :limit => 11,  :default => 0, :null => false
    t.datetime "last_read_at"
    t.integer  "comment_count",             :limit => 11,  :default => 0, :null => false
    t.datetime "last_comment_at"
    t.integer  "friendship_status",         :limit => 11,  :default => 0, :null => false
    t.integer  "votes_value",               :limit => 11,  :default => 0, :null => false
    t.datetime "last_viewed_at"
    t.integer  "last_viewed_entries_count", :limit => 11,  :default => 0, :null => false
    t.string   "title",                     :limit => 128
  end

  add_index "relationships", ["user_id", "reader_id"], :name => "index_relationships_on_user_id_and_reader_id", :unique => true
  add_index "relationships", ["user_id", "reader_id", "position"], :name => "index_relationships_on_user_id_and_reader_id_and_position"
  add_index "relationships", ["reader_id", "user_id", "position"], :name => "index_relationships_on_reader_id_and_user_id_and_position"
  add_index "relationships", ["reader_id", "votes_value"], :name => "index_relationships_on_reader_id_and_votes_value"
  add_index "relationships", ["reader_id", "friendship_status"], :name => "index_relationships_on_reader_id_and_friendship_status"

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sidebar_elements", :force => true do |t|
    t.integer "sidebar_section_id", :limit => 11, :null => false
    t.string  "type",               :limit => 25
    t.text    "content",                          :null => false
    t.integer "position",           :limit => 11
  end

  create_table "sidebar_sections", :force => true do |t|
    t.integer "user_id",  :limit => 11,                    :null => false
    t.string  "name",                                      :null => false
    t.integer "position", :limit => 11
    t.boolean "is_open",                :default => false, :null => false
  end

  add_index "sidebar_sections", ["user_id", "position"], :name => "index_sidebar_sections_on_user_id_and_position"

  create_table "social_ads", :force => true do |t|
    t.integer  "user_id",     :limit => 11,                    :null => false
    t.integer  "entry_id",    :limit => 11,                    :null => false
    t.string   "annotation",                                   :null => false
    t.datetime "created_at",                                   :null => false
    t.integer  "impressions", :limit => 11, :default => 0,     :null => false
    t.integer  "clicks",      :limit => 11, :default => 0,     :null => false
    t.boolean  "is_disabled",               :default => false, :null => false
  end

  add_index "social_ads", ["user_id", "entry_id"], :name => "index_social_ads_on_user_id_and_entry_id", :unique => true
  add_index "social_ads", ["created_at", "user_id"], :name => "index_social_ads_on_created_at_and_user_id"

  create_table "sphinx_counter", :id => false, :force => true do |t|
    t.integer "counter_id", :limit => 11
    t.integer "max_doc_id", :limit => 11
  end

  add_index "sphinx_counter", ["counter_id"], :name => "index_sphinx_counter_on_counter_id", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id",        :limit => 11
    t.integer  "taggable_id",   :limit => 11
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["taggable_id", "taggable_type", "tag_id"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_tag_id", :unique => true
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string "name", :default => "", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "tlog_backgrounds", :force => true do |t|
    t.integer "tlog_design_settings_id", :limit => 11
    t.string  "content_type"
    t.string  "filename"
    t.integer "size",                    :limit => 11
    t.integer "parent_id",               :limit => 11
    t.string  "thumbnail"
    t.integer "width",                   :limit => 11
    t.integer "height",                  :limit => 11
    t.integer "db_file_id",              :limit => 11
  end

  add_index "tlog_backgrounds", ["tlog_design_settings_id"], :name => "index_tlog_backgrounds_on_tlog_design_settings_id"

  create_table "tlog_design_settings", :force => true do |t|
    t.integer  "user_id",                         :limit => 11
    t.string   "theme"
    t.string   "background_url"
    t.string   "date_style"
    t.text     "user_css"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "color_bg",                        :limit => 6
    t.string   "color_tlog_text",                 :limit => 6
    t.string   "color_tlog_bg",                   :limit => 6
    t.string   "color_sidebar_text",              :limit => 6
    t.string   "color_sidebar_bg",                :limit => 6
    t.string   "color_link",                      :limit => 6
    t.string   "color_highlight",                 :limit => 6
    t.string   "color_date",                      :limit => 6
    t.string   "color_voter_bg",                  :limit => 6
    t.string   "color_voter_text",                :limit => 6
    t.boolean  "background_fixed",                              :default => false, :null => false
    t.boolean  "color_tlog_bg_is_transparent",                  :default => false, :null => false
    t.boolean  "color_sidebar_bg_is_transparent",               :default => false, :null => false
    t.boolean  "color_voter_bg_is_transparent",                 :default => false, :null => false
  end

  add_index "tlog_design_settings", ["user_id"], :name => "index_tlog_design_settings_on_user_id", :unique => true

  create_table "tlog_settings", :force => true do |t|
    t.integer  "user_id",                :limit => 11, :default => 0,              :null => false
    t.string   "title"
    t.text     "about"
    t.datetime "updated_at"
    t.string   "rss_link"
    t.boolean  "tasty_newsletter",                     :default => true,           :null => false
    t.string   "default_visibility",                   :default => "mainpageable", :null => false
    t.boolean  "comments_enabled",                     :default => false
    t.integer  "css_revision",           :limit => 11, :default => 1,              :null => false
    t.boolean  "sidebar_is_open",                      :default => true,           :null => false
    t.boolean  "is_daylog",                            :default => false,          :null => false
    t.boolean  "sidebar_hide_tags",                    :default => true,           :null => false
    t.boolean  "sidebar_hide_calendar",                :default => false,          :null => false
    t.boolean  "sidebar_hide_search",                  :default => false,          :null => false
    t.boolean  "sidebar_hide_messages",                :default => false,          :null => false
    t.string   "sidebar_messages_title"
    t.boolean  "email_messages",                       :default => true,           :null => false
  end

  add_index "tlog_settings", ["user_id"], :name => "index_tlog_settings_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.boolean  "is_confirmed",                          :default => false, :null => false
    t.string   "openid"
    t.string   "url",                                   :default => "",    :null => false
    t.text     "settings"
    t.boolean  "is_disabled",                           :default => false, :null => false
    t.datetime "created_at",                                               :null => false
    t.integer  "entries_count",           :limit => 11, :default => 0,     :null => false
    t.datetime "updated_at"
    t.boolean  "is_anonymous",                          :default => false, :null => false
    t.boolean  "is_mainpageable",                       :default => false, :null => false
    t.boolean  "is_premium",                            :default => false, :null => false
    t.string   "domain"
    t.integer  "private_entries_count",   :limit => 11, :default => 0,     :null => false
    t.boolean  "email_comments",                        :default => true,  :null => false
    t.boolean  "comments_auto_subscribe",               :default => true,  :null => false
    t.string   "gender",                  :limit => 1,  :default => "m",   :null => false
    t.string   "username"
    t.string   "salt",                    :limit => 40
    t.string   "crypted_password",        :limit => 40
    t.integer  "messages_count",          :limit => 11, :default => 0,     :null => false
    t.integer  "faves_count",             :limit => 11, :default => 0,     :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["openid"], :name => "index_users_on_openid"
  add_index "users", ["url"], :name => "index_users_on_url"
  add_index "users", ["domain"], :name => "index_users_on_domain"

end
