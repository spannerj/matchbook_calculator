require 'sinatra'
require 'money'

def calc_odds(back_odds, back_stake, lay_odds)

    result_hash = {}
    
    #### work out standard lay
    
    # start with a penny lay stake
    lay_stake = 9.70
    lay_search = true
    ul_search = true
    ol_search = true
    
    #loop until the back and lay results are equalised
    while lay_search || ul_search || ol_search do
        bw = back_wins(back_odds, back_stake, lay_stake, lay_odds)
        lw = lay_wins(back_stake, lay_stake)
        
        #puts 'ls - ' + lay_stake.to_s + ' bw - ' + bw.to_s + ' ---- lw ' + lw.to_s
        
        if (bw <= 0 || bw == 0) && ul_search
            result_hash['underlaystake'] = lay_stake.round(2)
            result_hash['underlaywin'] = bw * -1 #ensure no negative
            result_hash['underlayloss'] = lw
            ul_search = false
        end
            
        #increase the stake until the profit/loss equalises
        if bw > lw 
            result_hash['stake'] = lay_stake.round(2)
            result_hash['cost'] = bw
            result_hash['lay_cost'] = lw
            lay_search = false
        end
        
        if (lw >= 0 || lw == 0) && ol_search
            result_hash['overlaystake'] = lay_stake.round(2)
            result_hash['overlaywin'] = bw
            result_hash['overlayloss'] = lw #* -1 #ensure no negative
            ol_search = false
        end
        
            
        #increase the stake by a penny
        lay_stake = lay_stake + 0.01
    end
    
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
#   if number < 0
#     return "-£%.2f" % (number * -1).to_f 
#   else
#     return '£' + sprintf("%.02f", number)   
#   end     
    number
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
      @underlaystake = currency_format(res_hash['underlaystake'])
#      puts 'ulw ' + res_hash['underlaywin'].to_s
      @underlaywin = currency_format(res_hash['underlaywin'])
      @underlayloss = currency_format(res_hash['underlayloss'])
      @overlaystake = currency_format(res_hash['overlaystake']) 
      @overlaywin = currency_format(res_hash['overlaywin']) 
      @overlayloss = currency_format(res_hash['overlayloss'])
  end

  erb :calc
end