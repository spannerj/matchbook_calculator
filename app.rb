require 'sinatra'
require 'money'

def calc_odds(back_odds, back_stake, lay_odds)

    result_hash = {}
    
    #### work out standard lay
    
    # start with a penny lay stake
    lay_stake = 0.01
    cont = true
    
    #loop until the back and lay results are equalised
    while cont do
        bw = back_wins(back_odds, back_stake, lay_stake, lay_odds)
        lw = lay_wins(back_stake, lay_stake)
        
        #increase the stake until the profit/loss equalises
        if bw > lw 
            #increase the stake by a penny
            lay_stake = lay_stake + 0.01
        else
            cont = false
        end
    end

    result_hash['stake'] = lay_stake.round(2)
    result_hash['cost'] = bw
    result_hash['lay_cost'] = lw
    
    
    #### work out underlay
    
    # result_hash['underlaystake'] = back_stake
    # result_hash['underlosslose'] = 
    
    result_hash
end

#calculate the result if the back bet wins
def back_wins(back_odds, back_stake, lay_stake, lay_odds)
    
    back_return = back_stake * back_odds
    
    back_profit = back_return - back_stake
    
    lay_liability = lay_stake * (lay_odds - 1)
    
    if lay_odds < 2.0
        commision = (lay_liability * 0.0115)
    else
        commision = (lay_stake * 0.0115)
    end    
        
    (back_profit - commision - lay_liability).round(2)    
end

#calculate the result if the lay wins
def lay_wins(back_stake, lay_stake)
    (lay_stake - (lay_stake * 0.0115) - back_stake).round(2)
end

#format the currency
def currency_format(number)
  if number < 0
    return "-£%.2f" % (number * -1).to_f 
  else
    return '£' + sprintf("%.02f", number)   
  end      
end    

get '/' do
  @stake = params[:stake]
  @back = params[:back]
  @lay = params[:lay]
  if !params[:stake].nil? & !params[:back].nil? & !params[:lay].nil?
      res_hash = calc_odds( @back.to_f, @stake.to_f, @lay.to_f )
  
      @loss = currency_format(res_hash['cost'])
      @laystake = currency_format(res_hash['stake'])
      @lay_loss = currency_format(res_hash['lay_cost'])
      #@underlaystake = currency_format(res_hash['underlaystake'])
  end

  erb :calc
end