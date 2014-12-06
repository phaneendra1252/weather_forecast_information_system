class ImdAwsDataController < ApplicationController
  before_action :set_imd_aws_datum, only: [:show, :edit, :update, :destroy]
  before_action :set_imd_states

  respond_to :html

  def index
    @imd_aws_data = ImdAwsDatum.all
    respond_with(@imd_aws_data)
  end

  def show
    respond_with(@imd_aws_datum)
  end

  def new
    @imd_aws_datum = ImdAwsDatum.new
    respond_with(@imd_aws_datum)
  end

  def edit
  end

  def create
    @imd_aws_datum = ImdAwsDatum.new(imd_aws_datum_params)
    @imd_aws_datum.save
    respond_with(@imd_aws_datum)
  end

  def update
    @imd_aws_datum.update(imd_aws_datum_params)
    respond_with(@imd_aws_datum)
  end

  def destroy
    @imd_aws_datum.destroy
    respond_with(@imd_aws_datum)
  end

  def parse_imd_aws_data
    from_date = params["aws_data"]["from_date"]
    to_date = params["aws_data"]["to_date"]
    from_date = Date.parse(from_date).strftime("%d/%m/%Y")
    to_date = Date.parse(to_date).strftime("%d/%m/%Y")
    state_id = params["aws_data"]["state_id"]
    ImdAwsDatum.parse_imd_aws_data(from_date, to_date, state_id)
  end

  private
    def set_imd_aws_datum
      @imd_aws_datum = ImdAwsDatum.find(params[:id])
    end

    def set_imd_states
      @imd_states = ImdState.all
    end

    def imd_aws_datum_params
      params.require(:imd_aws_datum).permit(:sr_no, :station_name, :parse_date, :time_utc, :latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :imd_state_id)
    end
end
