class ProductsController < InheritedResources::Base
  before_action :authenticate_admin_user!, except: %i[index show show_picture down show_price reservation add_to_cart]
  add_breadcrumb 'Products', :products_path

  def new
    add_breadcrumb 'New', :new_product_path
    super
  end

  def edit
    @product = Product.find(params[:id])
    add_breadcrumb @product.name.to_s, product_path
    add_breadcrumb 'Edit', :edit_product_path
    super
  end

  def index
    @products = Product.all
    @products = @products.page(params[:page]).per(5)
    @view_model = HomePageViewModel.new
  end

  def show
    @product = Product.find(params[:id])
    add_breadcrumb @product.name.to_s, product_path
    @comments = Comment.new(product: @product)
    @bookings = Booking.new(product: @product)
  end

  def product_params
    params.require(:product).permit(:name, :remove_picture, :picture, :price, :description, :category, :amount)
  end

  def add_to_cart
    product = Product.find(params[:id])
    outcome = AddToCart.run(guest: current_guest, product: product)

    flash[:notice] = if outcome.valid?
                       'Dodano do koszyka'
                     else
                       outcome.errors.full_messages
                     end

    redirect_to products_path
  end
end
