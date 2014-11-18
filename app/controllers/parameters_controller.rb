class ParametersController < ApplicationController
  before_action :set_parameter, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @parameters = Parameter.all
    respond_with(@parameters)
  end

  def show
    respond_with(@parameter)
  end

  def new
    @parameter = Parameter.new
    respond_with(@parameter)
  end

  def edit
  end

  def create
    @parameter = Parameter.new(parameter_params)
    @parameter.save
    respond_with(@parameter)
  end

  def update
    @parameter.update(parameter_params)
    respond_with(@parameter)
  end

  def destroy
    @parameter.destroy
    respond_with(@parameter)
  end

  private
    def set_parameter
      @parameter = Parameter.find(params[:id])
    end

    def parameter_params
      params.require(:parameter).permit(:name)
    end
end
