class ConcertsController < ApplicationController 
  before_action :authenticate_user!, only: [:new, :create, :update]
  def index
    @concerts = Concert.all  
  end

  def show 
    @concert = Concert.find(params[:id])
  end

  def new
    @concert = Concert.new
  end

  def create
    @concert = Concert.new(concert_params)

    if @concert.save
      Concert::SEATS.values.flatten.each do |seat|
        @concert.tickets.create(seat: seat)
      end
      redirect_to @concert
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @concert = Concert.find(params[:id])
    if @concert.update(concert_params)
      redirect_to @concert
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @concert = Concert.find(params[:id])
    @concert.destroy
    TicketMailer.with(concert: @concert).ticket_deleted_email.deliver_now
    redirect_to root_path
  end

  private

  def concert_params
    params.require(:concert).permit(:title, :body, :price_balcony, :price_amphitheater, :price_ground_floor, :event_date, :event_time)
  end
end
