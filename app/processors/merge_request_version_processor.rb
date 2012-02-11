# encoding: utf-8
class MergeRequestVersionProcessor < ApplicationProcessor

  subscribes_to :merge_request_version_deletion

  def on_message(message)
    parse(message)
    delete_branch
  end

  def delete_branch
    begin
      source_repository.git.git.push({:timeout => false},
        tracking_repository_path,
        ":#{target_branch_name}")
    rescue 
      log_error("Unable to remove branch #{target_branch_name} in #{tracking_repository_path}")
    end
  end

  def parse(message)
    @message = JSON.parse(message)
  end

  def tracking_repository_path
    @message["tracking_repository_path"]
  end

  def source_repository_path
    @message["source_repository_path"]
  end

  def target_branch_name
    @message["target_branch_name"]
  end

  def source_repository
    Repository.find(@message["source_repository_id"])
  end

  def log_error(message)
    logger.error(message)
  end
      
end
