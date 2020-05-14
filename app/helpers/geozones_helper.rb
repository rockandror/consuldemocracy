module GeozonesHelper

  def geozone_name(geozonable)
    geozonable.geozone ? geozonable.geozone.name : t("geozones.none")
  end

  def geozone_select_options
    Geozone.all.order(name: :asc).collect { |g| [ g.name, g.id ] }
  end

  def borought_select_options
    Proposal.where("title NOT LIKE 'Toda la ciudad' AND comunity_hide IS TRUE").order(title: :asc).collect { |g| [ g.title, g.id ] }
  end

end
