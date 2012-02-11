# encoding: utf-8
class MergeRequestProcessor < ApplicationProcessor
  subscribes_to :mirror_merge_request

  def on_message(message)
    verify_connections!
    json = ActiveSupport::JSON.decode(message)
    merge_request_id = json['merge_request_id']
    # Find by id, as we're outside repository scope here 
    merge_request = MergeRequest.find(merge_request_id)
    if !merge_request.target_repository.has_tracking_repository?
      create_tracking_repository(merge_request)
    end
    logger.info("Pushing tracking branch for merge request #{merge_request.to_param} in repository #{merge_request.target_repository.name}'s tracking repository. Project slug is #{merge_request.target_repository.project.slug}")
    merge_request.push_to_tracking_repository!(true)
  end
  
  def create_tracking_repository(merge_request)
    tracking_repo = merge_request.target_repository.create_tracking_repository
    logger.info("Creating tracking repository at #{tracking_repo.real_gitdir} for merge request #{merge_request.to_param}")
    Repository.clone_git_repository(
      tracking_repo.real_gitdir, 
      merge_request.target_repository.real_gitdir,
      {:skip_hooks => true})
  end
end
