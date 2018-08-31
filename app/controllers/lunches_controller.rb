require 'shuffle'

class LunchesController < ApplicationController
  before_action :set_lunch, only: [:show, :edit, :update, :destroy]

  # GET /lunches
  # GET /lunches.json
  def index

  end

  def upload
    file = params[:file]
    @path = params[:path]

    if file.present?
      @path = Rails.root.join('tmp', file.original_filename)
      File.open(@path, 'w+b') do |f|
        f.write file.read
      end
    end

    @lunch_groups = Shuffle::generate(@path)
  end
end
