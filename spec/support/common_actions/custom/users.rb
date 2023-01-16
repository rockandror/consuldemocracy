module Users
  def expect_to_be_signed_in
    expect(find(".top-links")).to have_content "My account"
  end

  def expect_not_to_be_signed_in
    expect(find(".top-links")).not_to have_content "My account"
  end
end
