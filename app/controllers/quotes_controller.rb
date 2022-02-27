class QuotesController < ApplicationController
  before_action :authenticate

  def index
    render json: {error: 'Please inform a tag to search.'}, status: :bad_request
  end

  def quotes
    
    tag = params[:tag]

    # Request and save quotes in db
    Crawlers::QuotesCrawler.new.request_quotes(tag)

    # Get quotes from db
    data = Quote.where(tags: tag)

    # Render response
    render json: data, root: 'quotes', adapter: :json, each_serializer: QuoteSerializer

  end

  def clean
    tag = params[:tag]
    TagRequest.delete_all(tag: tag)
    render json: 
    "#{Quote.delete_all(tags: tag)} quote(s) removed from cache.\n#{tag} tag reset."

  end

  def reset
    tag = params[:tag]
    TagRequest.delete_all(tag: tag)
    render json: "#{tag} tag reset."
  end

  def clean_all
    t = TagRequest.delete_all()
    q = Quote.delete_all()
    render json: "#{q} quote(s) removed from cache.\n#{t} tag(s) reset."
  end
end
