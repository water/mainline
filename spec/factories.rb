FactoryGirl.define do
  factory :user do
    login { FactoryGirl.generate(:login) }
    email { FactoryGirl.generate(:email) }
    terms_of_use "1"
    password "password"
    password_confirmation { password }
    created_at Time.now.to_s(:db)
    is_admin false
    activated_at Time.now.to_s(:db)
    factory :admin do
      is_admin true
    end
  end

  factory :student do
    user
  end

  factory :comment do
    user
    body "This is a test"
  end

  factory :extended_deadline do
    at 3.days.from_now
    lab_has_group
  end

  factory :student_registered_for_course do
    student
    given_course
  end

  factory :administrator do
    user
  end

  factory :lab_has_group do    
    repository

    after_build do |lhg|
      if lab_group = lhg.lab_group
        gc ||= lab_group.try(:given_course)
      end

      if lab = lhg.lab
        gc ||= lab.try(:given_course)
      end

      gc ||= FactoryGirl.create(:given_course)

      lhg.lab ||= FactoryGirl.create(:active_lab, {
        given_course: gc
      })

      lhg.lab_group  ||= FactoryGirl.create(:lab_group, {
        given_course: gc
      })
    end
  end

  factory :lab do
    given_course
    lab_description
    factory :active_lab do
      active true
    end

    default_deadlines_attributes do 
      [FactoryGirl.attributes_for(:default_deadline_without_lab)]
    end
  end

  factory :default_deadline_without_lab, class: "DefaultDeadline" do
    sequence(:at) { |n| ((n + 1)*2).days.from_now }
    description "Lorem ipsum dolor sit amet"
    factory :default_deadline do
      lab do
        lab = FactoryGirl.create(:lab)
        lab.define_singleton_method :temp_fg_hack, lambda {}
        lab
      end

      after_create do |default_deadline, evaluator|
        if evaluator.lab.respond_to?(:temp_fg_hack)
          evaluator.lab.default_deadlines = [default_deadline]
          class << evaluator.lab
            remove_method(:temp_fg_hack)
          end
        end
        evaluator.lab.reload
      end
    end
  end

  factory :lab_description do
    description "This is a description"
    title "Lab title"
    association(:study_period)
  end

  factory :submission do
    commit_hash "6707a957d6ebe1b3df580343b9d57cc3c758cc9e"
    lab_has_group
  end

  factory :repository do
    factory :repo_with_data do
      ready true
      after_create do |r|
        Repository.create_git_repository(r.real_gitdir)
        dir = File.join(Rails.root, "spec/fixtures/git-repo")
        Dir.chdir(dir) do
          Kernel.system "git push #{r.full_repository_path} master"
        end
      end
    end
  end

  factory :given_course do
    course { FactoryGirl.create(:course_with_course_code) }
    examiners { [FactoryGirl.create(:examiner)] }
    association(:study_period)
  end

  factory :assistant do
    user
    given_courses { [FactoryGirl.create(:given_course)] }
    lab_groups { [FactoryGirl.create(:lab_group)] }
    all_lab_groups { [FactoryGirl.create(:lab_group)] }
  end

  factory :examiner do
    user
  end

  factory :lab_group do
    given_course
  end

  factory :department do
    sequence(:name) { |n| "Computer Science #{n}" }
  end

  factory :course_without_department, class: Course do
    course_codes { [FactoryGirl.create(:course_code)] }
  end

  factory :course_with_course_code, class: Course do
    course_codes { [FactoryGirl.create(:course_code)] }
    department
  end

  factory :course do
    department
  end

  factory :assistant_registered_for_course do |c|
    assistant
    can_change_deadline true
    given_course
  end

  factory :initial_lab_commit do
    repository
    commit_hash "6ff87c4664981e4397625791c8ea3bbb5f2279a3"
  end

  factory :initial_lab_commit_for_lab do
    lab
    initial_lab_commit
  end

  factory :course_code do
    sequence(:code) { |n| "TDA121#{n}#{Random.rand(10**10)}" }
  end

  factory :study_period do
    sequence(:year) { |n| 1950 + (n % 101) }
    sequence(:period)
  end

  factory :group do
    sequence(:name) { |n| "b-team_#{n}" }
    creator { FactoryGirl.create(:user) }
  end

  factory :message do
    sender { FactoryGirl.create(:user) }
    recipient { FactoryGirl.create(:user) }
    subject "Hello"
    body "Just called to say hi"
  end

  factory :project do
    slug "project"
    title "Test project"
    description "Random project"

    factory :user_project do
      user
      owner { FactoryGirl.create(:user) }
    end
  end

  sequence :key do |n|
    "ssh-rsa #{["abcdef#{n}"].pack("m")} foo#{n}@bar"
  end

  factory :ssh_key do
    user
    sequence(:key) { FactoryGirl.generate(:key) }
    ready true
  end

  sequence :email do |n|
    "john#{n}#{Random.rand(10**10)}@example.com"
  end

  sequence :login do |n|
    "user#{n}#{Random.rand(10**10)}"
  end
end
