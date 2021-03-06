class GatheringsController < ApplicationController
  include UseCases
  
  before_filter :authenticate_user!
  respond_to :html
  
  def use(atts = {})
    atts.merge!(:user => current_user)
    GatheringUseCase.new(atts)
  end
  
  def index
    @vm = use.list
    respond_with @vm
  end

  def show
    @vm = use(:id => params[:id]).show
    respond_with @vm do |format|
      format.html {
        if @vm.errors
          redirect_to gatherings_path, :alert => "Gathering with id #{params[:id]} does not exist." if @vm.errors[:record_not_found]
        end
      }
    end
  end

  def edit
    @vm = use(:id => params[:id]).edit
    respond_with @vm
  end

  def new
    @vm = use.new
    respond_with @vm
  end

  def create
    @vm = use(:atts => params[:gathering]).create
    respond_with @vm do |format|
      format.html { 
        if @vm.ok?
          redirect_to gathering_path(@vm.gathering)
        else
          render 'new', :alert => "Error: Unable to save gathering"
        end
      }
    end
    
  end

  def update
    @vm = use(:id => params[:id], :atts => params[:gathering]).update
    respond_with @vm do |format|
      format.html { 
        if @vm.ok?
          redirect_to gathering_path(@vm.gathering)
        else
          render 'edit', :flash => "Error: Unable to save gathering"
        end
      }
    end
  end

  def destroy
    @vm = use(:id => params[:id], :ability => current_ability).destroy
    
    if @vm.ok?
      flash[:flash] = "Gathering destroyed"
    else
      flash[:flash] = "Gathering could not be destroyed."
    end
    
    respond_with @vm do |format|
      format.html {
        redirect_to gatherings_path
      }
    end
  end
end
