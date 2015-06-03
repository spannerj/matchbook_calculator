require 'sinatra'

def calc_odds(back_odds, back_stake, lay_odds)

    result_hash = {}
    
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
            #close match found so break the loop
            cont = false
        end
    end

    result_hash['stake'] = lay_stake.round(2)
    result_hash['cost'] = bw
    
    result_hash
end

#calculate the result if the back bet wins
def back_wins(back_odds, back_stake, lay_stake, lay_odds)
    
    back_win = back_odds * back_stake
    
    if back_win - back_stake < back_stake
        com = back_win * 0.0115 
    else
        com = back_stake * 0.0115
    end

    back_profit = back_win - back_stake
    
    (back_profit - ((lay_stake * lay_odds) - lay_stake) - com).round(2)  
end

#calculate the result if the lay wins
def lay_wins(back_stake, lay_stake)
    (lay_stake - back_stake - (lay_stake * 0.0115)).round(2)
end

get '/' do
  @stake = params[:stake]
  @back = params[:back]
  @lay = params[:lay]
  if !params[:stake].nil? & !params[:back].nil? & !params[:lay].nil?
      res_hash = calc_odds(1.76, 100, 1.807)
      @loss = res_hash['cost']
      @laystake = res_hash['stake']
  end
  erb :calc
end