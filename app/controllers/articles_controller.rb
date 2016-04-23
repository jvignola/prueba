class ArticlesController < ApplicationController

	before_action :authenticate_user!, except:[:show, :index]
	before_action :set_article, only:[:show, :edit, :update, :destroy, :publish]
	before_action :authenticate_editor!, only:[:new, :create, :update]
	before_action :authenticate_admin!, only:[:destroy, :publish]
	#GET /articles
	def index
		@articles = Article.paginate(page: params[:page], per_page: 9).publicados.ultimos
	end

	#GET /articles/:id
	def show
		#encontrar por id
		#@article = Article.find(params[:id])
		# where
		# Article.where.not("body LIKE ?", "%hola%")
		@article.update_visits_count
		@comment = Comment.new
	end

	#GET /articles/new
	def new
		@article = Article.new
		@categories = Category.all
	end

	#POST /articles
	def create
		@article = current_user.articles.new(article_params)
		@article.categories = params[:categories]
		if @article.save
			redirect_to @article
		else
			render :new
		end
	end

	def edit
		#@article = Article.find(params[:id])
	end

	#PUT /articles/:id
	def update
		#@article = Article.find(params[:id])
		if @article.update(article_params)
			redirect_to @article
		else
			render :edit
		end
	end

	# DELETE /articles/:id
	def destroy
		#@article = Article.find(article_params)
		@article.destroy #elimina objeto de la BD
		redirect_to articles_path
	end

	def publish
		@article.publish!
		redirect_to @article
	end

	private

	def set_article
		@article = Article.find(params[:id])
	end

	def article_params
		params.require(:article).permit(:title,:body,:cover,:categories,:markup_body)
	end
end