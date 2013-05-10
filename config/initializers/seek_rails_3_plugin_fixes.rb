#A placeholder for little hacks required to get various plugins working during the upgrade to rails 3
#these are items that will need revisiting
require 'bioportal'

SEEK::Application.configure do

  #FIXME: having to do this suggests the gem init.rb isn't being invoked
  ActiveRecord::Base.send(:include,SiteAnnouncements::Acts)
  require_dependency File.join(Gem.loaded_specs['site_announcements'].full_gem_path,'app','models',"notifiee_info")

  require_dependency File.join(Gem.loaded_specs['my_savage_beast'].full_gem_path,'app','models',"monitorship")
  require_dependency File.join(Gem.loaded_specs['my_savage_beast'].full_gem_path,'app','models',"posts_sweeper")


  require_dependency File.join(Gem.loaded_specs['bioportal'].full_gem_path,'app','helpers',"bio_portal_helper")
  require_dependency File.join(Gem.loaded_specs['bioportal'].full_gem_path,'app','models',"bioportal_concept")
  #ActionView::Base.send(:include, BioPortal::BioPortalHelper)
  ActiveRecord::Base.send(:include,BioPortal::Acts)
end
