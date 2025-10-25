module Api
  module V1
    class BooksController < BaseController
      before_action :set_book, only: %i[show update destroy]

      # GET /api/v1/books
      def index
        @books = Book.all
        render json: @books
      end

      # GET /api/v1/books/:id
      def show
        render json: @book
      end

      # POST /api/v1/books
      def create
        @book = Book.new(book_params)

        if @book.save
          render json: @book, status: :created
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/books/:id
      def update
        if @book.update(book_params)
          render json: @book, status: :ok
        else
          render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/books/:id
      def destroy
        @book.destroy!
        head :no_content
      end

      private

      def set_book
        @book = Book.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Book not found' }, status: :not_found
      end

      def book_params
        params.require(:book).permit(:title, :body)
      end
    end
  end
end
