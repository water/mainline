class SubmissionsController < ApplicationController
  layout "water"
  def index
  end

  def show
  end

  def create
  end

  def new
    # mock!
    # prepare_tree
    flash[:notice] = "Incredibly useless message."
  end
  
  def mock!
    @repository = Repository.find(6)
    @project = Project.find(4)
    params[:branch_and_path] = "master"
  end
  
  protected
  def prepare_tree
    @git = @repository.git
    @ref, @path = branch_and_path(params[:branch_and_path], @git)
    unless @commit = @git.commit(@ref)
      handle_missing_tree_sha and return
    end
    if stale_conditional?(Digest::SHA1.hexdigest(@commit.id + 
      (params[:branch_and_path].kind_of?(Array) ? params[:branch_and_path].join : params[:branch_and_path])), 
                          @commit.committed_date.utc)
      head = @git.get_head(@ref) || Grit::Head.new(@commit.id_abbrev, @commit)
      @root = Breadcrumb::Folder.new({:paths => @path, :head => head, 
                                      :repository => @repository})
      path = @path.blank? ? [] : ["#{@path.join("/")}/"] # FIXME: meh, this sux
      @tree = @git.tree(@commit.tree.id, path)
      expires_in 30.seconds
    end
  end
  def handle_missing_tree_sha
      flash[:error] = "No such tree SHA1 was found"
      redirect_to project_repository_tree_path(@project, @repository, 
                      branch_with_tree("HEAD", @path || []))
  end
end
