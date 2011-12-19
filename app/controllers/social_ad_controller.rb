class SocialAdController < ApplicationController

  def click
    ad = SocialAd.find(params[:id], :include => [:entry, :user])
    ad.click!
    redirect_to entry_url(:id => ad.entry_id, :host => host_for_tlog(ad.user))
  end

end