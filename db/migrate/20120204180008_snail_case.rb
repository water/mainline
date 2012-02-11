class SnailCase < ActiveRecord::Migration
  def self.up
    rename_column :administrators, :User_id, :user_id
    rename_column :assistant_registered_to_given_courses, :GivenCourse_id, :given_course_id
    rename_column :assistant_registered_to_given_courses, :Assistant_id, :assistant_id
    rename_column :assistants, :User_id, :user_id
    rename_column :course_codes, :Course_id, :course_id
    rename_column :examiners, :User_id, :user_id
    rename_column :given_courses, :Course_id, :course_id
    rename_column :given_courses, :Examiner_id, :examiner_id
    rename_column :given_courses, :When_id, :when_id
    rename_column :group_has_users, :Student_id, :student_id
    rename_column :group_has_users, :LabGroup_id, :lab_group_id
    rename_column :initial_lab_commits, :Repository_id, :repository_id
    rename_column :lab_deadlines, :Lab_id, :lab_id
    rename_column :lab_descriptions, :When_id, :when_id
    rename_column :lab_groups, :RegisteredCourse_id, :registered_course_id
    rename_column :lab_has_groups, :LabGroup_id, :lab_group_id
    rename_column :lab_has_registered_assistants, :AssistantRegisteredToGivenCourse_id, :assistant_registered_to_given_course_id
    rename_column :lab_has_registered_assistants, :When_id, :when_id
    rename_column :lab_has_registered_assistants, :Lab_id, :lab_id
    rename_column :registered_courses, :Student_id, :student_id
    rename_column :registered_courses, :GivenCourse_id, :given_course_id
    rename_column :students, :User_id, :user_id
    rename_column :submissions, :LabHasGroup_id, :lab_has_group_id
  end

  def self.down
  end
end
