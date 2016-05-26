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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160526060908) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: :cascade do |t|
    t.text     "content"
    t.integer  "question_id"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "response_id"
    t.string   "photo"
    t.string   "photo_secure_token"
    t.string   "photo_tmp"
    t.integer  "record_id"
    t.integer  "photo_file_size"
    t.boolean  "photo_processing",   default: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["response_id"], name: "index_answers_on_response_id", using: :btree

  create_table "brochure_enquiries", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "count",      default: 0, null: false
    t.boolean  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: :cascade do |t|
    t.integer  "category_id"
    t.text     "content"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "survey_id"
    t.integer  "order_number"
    t.integer  "parent_id"
    t.string   "type"
    t.boolean  "mandatory",    default: false
    t.boolean  "finalized",    default: false
  end

  add_index "categories", ["category_id"], name: "index_categories_on_category_id", using: :btree

  create_table "choices", force: :cascade do |t|
    t.integer  "answer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "option_id"
  end

  add_index "choices", ["answer_id"], name: "index_choices_on_answer_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "options", force: :cascade do |t|
    t.string   "content"
    t.integer  "question_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "order_number"
    t.boolean  "finalized",    default: false
  end

  add_index "options", ["question_id"], name: "index_options_on_question_id", using: :btree

  create_table "participating_organizations", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "organization_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "content"
    t.integer  "survey_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.boolean  "mandatory",                    default: false
    t.integer  "max_length",         limit: 8
    t.string   "type"
    t.integer  "max_value",          limit: 8
    t.integer  "min_value"
    t.integer  "order_number"
    t.integer  "parent_id"
    t.boolean  "identifier",                   default: false
    t.integer  "category_id"
    t.string   "image"
    t.string   "photo_secure_token"
    t.boolean  "private",                      default: false
    t.boolean  "finalized",                    default: false
    t.integer  "photo_file_size"
  end

  add_index "questions", ["survey_id"], name: "index_questions_on_survey_id", using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "response_id"
  end

  create_table "respondents", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "user_id"
    t.string   "respondent_json"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "response_id"
    t.integer  "organization_id"
    t.string   "location"
  end

  create_table "responses", force: :cascade do |t|
    t.integer  "survey_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "user_id"
    t.integer  "organization_id"
    t.string   "status",          default: "incomplete"
    t.string   "session_token"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "location"
    t.string   "ip_address"
    t.string   "mobile_id"
    t.string   "state",           default: "clean"
    t.text     "comment"
    t.boolean  "blank",           default: false
    t.datetime "completed_at"
  end

  add_index "responses", ["organization_id"], name: "index_responses_on_organization_id", using: :btree
  add_index "responses", ["survey_id"], name: "index_responses_on_survey_id", using: :btree

  create_table "survey_users", force: :cascade do |t|
    t.integer  "survey_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "surveys", force: :cascade do |t|
    t.string   "name"
    t.date     "expiry_date"
    t.text     "description"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "finalized",           default: false
    t.integer  "organization_id"
    t.boolean  "public",              default: false
    t.string   "auth_key"
    t.date     "published_on"
    t.boolean  "archived",            default: false
    t.text     "thank_you_message"
    t.boolean  "marked_for_deletion", default: false
    t.integer  "parent_id"
  end

  add_index "surveys", ["organization_id"], name: "index_surveys_on_organization_id", using: :btree

end
