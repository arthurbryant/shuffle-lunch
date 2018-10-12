class LunchesController < ApplicationController
  before_action :set_lunch, only: [:show, :edit, :update, :destroy]

  # GET /lunches
  # GET /lunches.json
  def index

  end

  def upload
    file = lunch_params[:file]
    @path = lunch_params[:path]
    @group_size = lunch_params[:group_size]

    if file.present?
      @path = Rails.root.join('tmp', file.original_filename)
      File.open(@path, 'w+b') do |f|
        f.write file.read
      end
    end

    # replace this company.yml with your own yaml file
    config_path = Rails.root.join('config', 'shuffle', 'company.yml')
    @groups = ShuffleService.call(file_path: @path, group_size: @group_size, config_path: config_path)
  end

  def lunch_params
    params.permit(:file, :group_size, :path)
  end
end
