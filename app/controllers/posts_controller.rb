class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @q = Post.includes(:tags).ransack(params[:q])
    @posts = @q.result(distinct: true)

    # タグでの単一検索処理
    if params[:q].present? && params[:q][:tags_name_in].present? && params[:q][:tags_name_in].strip.present?
      selected_tag = params[:q][:tags_name_in].strip
      # 選択されたタグを持つ投稿のみを検索
      @posts = @posts.joins(:tags).where(tags: { name: selected_tag })
    end

    @all_tags = Tag.order(:name)
  end  # GET /posts/1 or /posts/1.json
  def show
    @post = Post.includes(:tags).find(params[:id])
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @post = Post.includes(:tags).find(params[:id])
    @post.tag_names = @post.tag_names_as_string
  end

  # POST /posts or /posts.json
  def create
    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to @post, notice: "Post was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, notice: "Post was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:title, :description, :tag_names)
    end
end
