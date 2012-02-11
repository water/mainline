# encoding: utf-8
class MergeRequestGitBackendProcessor < ApplicationProcessor

  subscribes_to :merge_request_backend_updates

  def on_message(message)
    verify_connections!
    @body = ActiveSupport::JSON.decode(message)
    send("do_#{action}")
  end

  def action
    @body["action"].to_sym
  end

  def source_repository
    @source_repository ||= Repository.find(@body["source_repository_id"])
  end

  def target_repository
    @target_repository ||= Repository.find(@body["target_repository_id"])
  end

  def delete_target_repository_ref
    source_repository.git.git.push({:timeout => false},
      target_repository.full_repository_path,
      ":#{@body['merge_branch_name']}")
  end

  private
  def do_delete
    logger.info("Deleting tracking branch #{@body['merge_branch_name']} for merge request " +
      "in target repository #{@body['target_name']}")
    begin
      delete_target_repository_ref
    rescue Grit::NoSuchPathError => e
      logger.error "Could not find Git path. Message is #{e.message}"
    rescue ActiveRecord::RecordNotFound => rfe
      logger.error "Could not find repository, it may have been deleted. Message is #{rfe.message}"
    end
  end
end
