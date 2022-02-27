class QuoteJob < ApplicationJob
  queue_as :default

  def perform(*args)
    #Adicional para que demore um pouco o Job
 
  end
end
