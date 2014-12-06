class ImdStatesController < ApplicationController
  before_action :set_imd_state, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @imd_states = ImdState.all
    respond_with(@imd_states)
  end

  def show
    respond_with(@imd_state)
  end

  def new
    @imd_state = ImdState.new
    respond_with(@imd_state)
  end

  def edit
  end

  def create
    @imd_state = ImdState.new(imd_state_params)
    @imd_state.save
    respond_with(@imd_state)
  end

  def update
    @imd_state.update(imd_state_params)
    respond_with(@imd_state)
  end

  def destroy
    @imd_state.destroy
    respond_with(@imd_state)
  end

  private
    def set_imd_state
      @imd_state = ImdState.find(params[:id])
    end

    def imd_state_params
      params.require(:imd_state).permit(:name, :code)
    end
end
