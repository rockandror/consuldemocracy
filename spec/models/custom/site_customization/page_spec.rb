require "rails_helper"

describe SiteCustomization::Page do
  describe ".search" do
    it "finds pages searching by title or slug" do
      page1 = create(:site_customization_page, title: "Page 1", slug: "page-one")
      page2 = create(:site_customization_page, title: "Page 2", slug: "page-two")

      expect(SiteCustomization::Page.search(text: "1")).to eq([page1])
      expect(SiteCustomization::Page.search(text: "2")).to eq([page2])
      expect(SiteCustomization::Page.search(text: "page-")).to match_array [page1, page2]
    end

    context "by type" do
      before do
        SiteCustomization::Page.delete_all
      end

      it "finds all pages searching by 'All'" do
        news_page = create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        custom_page = create(:site_customization_page, title: "Page 2", slug: "page-2")

        expect(SiteCustomization::Page.search(type: "all")).to match_array [news_page, custom_page]
      end

      it "finds news pages searching by 'News'" do
        news_page = create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        create(:site_customization_page, title: "Page 2", slug: "page-2")

        expect(SiteCustomization::Page.search(type: "news")).to eq [news_page]
      end

      it "finds other pages searching by 'Others'" do
        create(:site_customization_page, :news, title: "Page 1", slug: "page-1")
        custom_page = create(:site_customization_page, title: "Page 2", slug: "page-2")

        expect(SiteCustomization::Page.search(type: "others")).to eq [custom_page]
      end
    end

    context "by dates" do
      before do
        SiteCustomization::Page.delete_all
      end

      context "start_date" do
        it "finds pages searching by 'created_at'" do
          create(:site_customization_page, title: "Page", slug: "page-1", created_at: 1.day.ago)
          page2 = create(:site_customization_page, title: "Page 2", slug: "page-2")

          expect(SiteCustomization::Page.search(start_date: Date.current)).to eq [page2]
        end

        it "finds pages searching by 'news_date'" do
          create(:site_customization_page, :news, title: "Page 1",
                                                  slug: "page-1",
                                                  news_date: 1.day.ago,
                                                  created_at: 1.day.ago)
          news_page = create(:site_customization_page, :news, title: "Page 2",
                                                              slug: "page-2",
                                                              news_date: 1.day.from_now,
                                                              created_at: 1.day.ago)

          expect(SiteCustomization::Page.search(type: "all", start_date: Date.current)).to eq [news_page]
        end
      end

      context "end_date" do
        it "finds pages searching by 'created_at'" do
          page1 = create(:site_customization_page, title: "Page 1", slug: "page-1", created_at: 1.day.ago)
          create(:site_customization_page, title: "Page 2", slug: "page-2")

          expect(SiteCustomization::Page.search(end_date: Date.current)).to eq [page1]
        end

        it "finds pages searching by 'news_date'" do
          news_page = create(:site_customization_page, :news, title: "Page 1",
                                                              slug: "page-1",
                                                              news_date: 1.day.ago)
          create(:site_customization_page, :news, title: "Page 2",
                                                  slug: "page-2",
                                                  news_date: 1.day.from_now)

          expect(SiteCustomization::Page.search(type: "all", end_date: Date.current)).to eq [news_page]
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
