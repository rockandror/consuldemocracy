require "rails_helper"

describe SiteCustomization::Page do
  describe ".search" do
    it "finds pages searching by title or slug" do
      page1 = create(:site_customization_page, title: "Page 1", slug: "page-one")
      page2 = create(:site_customization_page, title: "Page 2", slug: "page-two")

      search_params = { text: "1", start_date: "", end_date:"" }
      expect(SiteCustomization::Page.search(search_params)).to eq([page1])

      search_params = { text: "2", start_date: "", end_date:"" }
      expect(SiteCustomization::Page.search(search_params)).to eq([page2])

      search_params = { text: "page-", start_date: "", end_date:"" }
      expect(SiteCustomization::Page.search(search_params)).to match_array [page1, page2]
    end

    context "by type" do
      before do
        SiteCustomization::Page.delete_all
      end

      it "finds pages searching by 'Todos'" do
        news_page = create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        custom_page = create(:site_customization_page, title: "Page 2", slug: "page-2")

        search_params = { type: "Todos", text: "", start_date: "", end_date:"" }
        expect(SiteCustomization::Page.search(search_params)).to match_array [news_page, custom_page]
      end

      it "finds pages searching by 'Noticias'" do
        news_page = create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        custom_page = create(:site_customization_page, title: "Page 2", slug: "page-2")

        search_params = { type: "Noticias", text: "", start_date: "", end_date: "" }
        expect(SiteCustomization::Page.search(search_params)).to eq [news_page]
      end

      it "finds pages searching by 'Otros'" do
        news_page = create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        custom_page = create(:site_customization_page, title: "Page 2", slug: "page-2")

        search_params = { type: "Otros", text: "", start_date: "", end_date: "" }
        expect(SiteCustomization::Page.search(search_params)).to eq [custom_page]
      end
    end

    context "by dates" do
      before do
        SiteCustomization::Page.delete_all
      end

      context "start_date" do
        it "finds pages searching by 'created_at'" do
          page1 = create(:site_customization_page, title: "Page", slug: "page-1", created_at: 1.day.ago)
          page2 = create(:site_customization_page, title: "Page 2", slug: "page-2")

          search_params = { text: "", start_date: Date.current, end_date: "" }
          expect(SiteCustomization::Page.search(search_params)).to eq [page2]
        end

        it "finds pages searching by 'news_date'" do
          news_page1 = create(:site_customization_page, :news, title: "Page 1", slug: "page-1",
                                news_date: 1.day.ago, created_at: 1.day.ago
                              )
          news_page2 = create(:site_customization_page, :news, title: "Page 2", slug: "page-2",
                                news_date: 1.day.from_now, created_at: 1.day.ago
                              )

          search_params = { type: "Todos", text: "", start_date: Date.current, end_date: "" }
          expect(SiteCustomization::Page.search(search_params)).to eq [news_page2]
        end
      end

      context "end_date" do
        it "finds pages searching by 'created_at'" do
          page1 = create(:site_customization_page, title: "Page 1", slug: "page-1", created_at: 1.day.ago)
          page2 = create(:site_customization_page, title: "Page 2", slug: "page-2")

          search_params = { text: "", start_date: "", end_date: Date.current }
          expect(SiteCustomization::Page.search(search_params)).to eq [page1]
        end

        it "finds pages searching by 'news_date'" do
          news_page1 = create(:site_customization_page, :news, title: "Page 1", slug: "page-1",
                                news_date: 1.day.ago)
          news_page2 = create(:site_customization_page, :news, title: "Page 2", slug: "page-2",
                                news_date: 1.day.from_now)

          search_params = { type: "Todos", text: "", start_date: "", end_date: Date.current }
          expect(SiteCustomization::Page.search(search_params)).to eq [news_page1]
        end
      end
    end
  end

  describe ".quick_search" do
    it "returns no pages if search term is blank" do
      create(:site_customization_page)

      search_params = { text: "", start_date: "", end_date: "" }

      expect(SiteCustomization::Page.quick_search(search_params)).to be_empty
    end
  end
end
