class App.CommitRequest extends Spine.Model
  @configure 'CommitRequest', 'command', 'user', 'repository', 'branch', 'commit_message'
  @extend Spine.Model.Ajax