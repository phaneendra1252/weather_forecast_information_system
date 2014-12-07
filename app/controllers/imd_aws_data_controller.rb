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
    imd_state_code = params["aws_data"]["imd_state_code"]
    response = ImdAwsDatum.parse_imd_aws_data(from_date, to_date, imd_state_code)
    if response[:status]
      redirect_to "/imd_aws_data", notice: "Imd Aws Data added successfully"
    else
      redirect_to "/imd_aws_data", alert: "Imd Aws Data failed to save because of #{response[:error_messages]}"
    end
  end

  private
    def set_imd_aws_datum
      @imd_aws_datum = ImdAwsDatum.find(params[:id])
    end

    def set_imd_states
      @imd_states = ImdState.all
    end

    def imd_aws_datum_params
      params.require(:imd_aws_datum).permit(:sr_no, :station_name, :parse_date, :time_utc, :latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg, :tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm, :imd_state_id)
    end
end
