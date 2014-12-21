class ImdAwsDataController < ApplicationController
  # before_action :set_imd_aws_datum, only: [:show, :edit, :update, :destroy]
  before_action :set_imd_states

  respond_to :html

  def index
    @search = ImdAwsDatum.search(params[:q])
    @imd_aws_data = @search.result
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    # @imd_aws_data = @search.result.page(params[:page]).per(100)
    @imd_aws_data = Kaminari.paginate_array(@imd_aws_data).page(params[:page]).per(100)
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

  private
    def set_imd_aws_datum
      @imd_aws_datum = ImdAwsDatum.find(params[:id])
    end

    def imd_aws_datum_params
      params.require(:imd_aws_datum).permit(:sr_no, :station_name, :parse_date, :time_utc, :latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg, :tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm, :imd_state_id)
    end
end
