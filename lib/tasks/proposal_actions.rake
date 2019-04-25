namespace :proposal_actions do
  desc "Move link attribute to links collection"
  task migrate_links: :environment do
    ProposalDashboardAction.where.not(link: nil).each do |action|
      next if action.link.blank?

      Link.create!(
        label: action.title,
        url: action.link,
        linkable: action
      )
    end
  end

  desc "Initialize proposal settings"
  task initialize_settings: :environment do
    %w[
      proposals.successful_proposal_id
      proposals.poll_short_title
      proposals.poll_description
      proposals.poll_link
      proposals.email_short_title
      proposals.email_description
      proposals.poster_short_title
      proposals.poster_description
    ].each do |key|
      Setting[key] = nil if Setting.find_by(key: key).nil?
    end
  end

  desc "Publish all proposals"
  task publish_all: :environment do
    Proposal.draft.find_each do |proposal|
      proposal.update_columns(published_at: proposal.created_at, updated_at: Time.current)
    end
  end

  desc "Simulate successful proposal"
  task create_successful_proposal: :environment do
    expected_supports = [
      1049,
      596,
      273,
      208,
      97,
      74,
      148,
      116,
      83,
      62,
      42,
      20,
      36,
      40,
      44,
      38,
      45,
      17,
      15,
      15,
      10,
      28,
      22,
      32,
      26,
      15,
      16,
      21,
      26,
      25,
      14,
      12,
      11,
      18,
      27,
      27,
      22,
      119,
      103,
      65,
      79,
      140,
      96,
      102,
      96,
      65,
      42,
      39,
      108,
      380,
      424,
      302,
      233,
      98,
      88,
      78,
      149,
      202,
      137,
      135,
      48,
      52,
      90,
      47,
      120,
      83,
      55,
      29,
      38,
      51,
      64,
      105,
      27,
      17,
      8,
      13,
      16,
      118,
      105,
      69,
      136,
      85,
      50,
      32,
      32,
      34,
      38,
      24,
      23,
      34,
      16,
      41,
      22,
      13,
      17,
      44,
      98,
      52,
      42,
      38,
      12,
      7,
      14,
      14,
      25,
      20,
      21,
      10,
      10,
      11,
      22,
      44,
      28,
      9,
      35,
      30,
      24,
      22,
      91,
      41,
      34,
      42,
      23,
      21,
      18,
      18,
      19,
      21,
      58,
      31,
      30,
      24,
      38,
      32,
      20,
      372,
      520,
      178,
      85,
      150,
      562,
      212,
      110,
      50,
      49,
      53,
      69,
      134,
      78,
      42,
      62,
      76,
      141,
      101,
      196,
      209,
      196,
      211,
      165,
      181,
      361,
      736,
      325,
      194,
      194,
      126,
      122,
      143,
      186,
      339,
      169,
      97,
      125,
      120,
      152,
      88,
      27,
      45,
      23,
      35,
      39,
      53,
      40,
      23,
      26,
      22,
      20,
      30,
      18,
      22,
      15,
      50,
      42,
      23,
      11,
      94,
      113,
      115,
      122,
      159,
      184,
      173,
      211,
      161,
      144,
      115,
      99,
      80,
      77,
      123,
      355,
      338,
      226,
      201,
      70,
      47,
      117,
      116,
      61,
      79,
      284,
      607,
      565,
      541,
      347,
      265,
      204,
      158,
      127,
      110,
      173,
      137,
      92,
      135,
      95,
      104,
      131,
      106,
      103,
      85,
      81,
      46,
      58,
      88,
      108,
      85,
      78,
      52,
      39,
      21,
      33,
      50,
      57,
      53,
      32,
      263,
      162,
      89,
      142,
      70,
      48,
      39,
      26,
      19,
      25,
      24,
      36,
      48,
      48,
      26,
      19,
      40,
      1916,
      535,
      214,
      106,
      73,
      50,
      42,
      62,
      54,
      54,
      82,
      124,
      112,
      104,
      328,
      256,
      309,
      547,
      68,
      27,
      41,
      55,
      55,
      37,
      32,
      29,
      14,
      18,
      23,
      21,
      18,
      11,
      10,
      16,
      12,
      49,
      74,
      230,
      110,
      63,
      17,
      14,
      26,
      300,
      137,
      45,
      25,
      7,
      6,
      19,
      12,
      7,
      53,
      53,
      14,
      14,
      17,
      10,
      8,
      6,
      5,
      7,
      5,
      3,
      5,
      5,
      4,
      4,
      3,
      1,
      4,
      7,
      7,
      5,
      6,
      3,
      3,
      8,
      6,
      6,
      4,
      7,
      4,
      5,
      9,
      5,
      1,
      3,
      4,
      1,
      2,
      5,
      4,
      3,
      5
    ]

    votes_count = expected_supports.inject(0.0) { |sum, x| sum + x }
    goal_votes = Setting["votes_for_proposal_success"].to_f
    cached_votes_up = 0

    tags = Faker::Lorem.words(25)
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                description: description,
                                created_at: Time.now - expected_supports.length.days,
                                tag_list: tags.sample(3).join(","),
                                geozone: Geozone.all.sample,
                                skip_map: "1",
                                terms_of_service: "1",
                                published_at: Time.now - expected_supports.length.days)


    expected_supports.each_with_index do |supports, day_offset|
      supports = (supports * goal_votes / votes_count).ceil
      cached_votes_up += supports

      supports.times do |i|
        user = User.create!(
          username: "user_#{proposal.id}_#{day_offset}_#{i}",
          email: "user_#{proposal.id}_#{day_offset}_#{i}@consul.dev",
          password: "12345678",
          password_confirmation: "12345678",
          confirmed_at: Time.current - expected_supports.length.days,
          terms_of_service: "1",
          gender: ["Male", "Female"].sample,
          date_of_birth: rand((Time.current - 80.years)..(Time.current - 16.years)),
          public_activity: (rand(1..100) > 30)
        )

        Vote.create!(
          votable: proposal,
          voter: user,
          vote_flag: false,
          vote_weight: 1,
          created_at: proposal.published_at + day_offset.days,
          updated_at: proposal.published_at + day_offset.days
        )
      end
    end

    Setting["proposals.successful_proposal_id"] = proposal.id
    proposal.update(cached_votes_up: cached_votes_up)
  end
end
