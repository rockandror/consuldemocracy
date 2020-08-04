require 'test_helper'

class Admin::SiteCustomization::MemberTypesControllerTest < ActionController::TestCase
  setup do
    @admin_site_customization_member_type = admin_site_customization_member_types(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:admin_site_customization_member_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create admin_site_customization_member_type" do
    assert_difference('Admin::SiteCustomization::MemberType.count') do
      post :create, admin_site_customization_member_type: {  }
    end

    assert_redirected_to admin_site_customization_member_type_path(assigns(:admin_site_customization_member_type))
  end

  test "should show admin_site_customization_member_type" do
    get :show, id: @admin_site_customization_member_type
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @admin_site_customization_member_type
    assert_response :success
  end

  test "should update admin_site_customization_member_type" do
    patch :update, id: @admin_site_customization_member_type, admin_site_customization_member_type: {  }
    assert_redirected_to admin_site_customization_member_type_path(assigns(:admin_site_customization_member_type))
  end

  test "should destroy admin_site_customization_member_type" do
    assert_difference('Admin::SiteCustomization::MemberType.count', -1) do
      delete :destroy, id: @admin_site_customization_member_type
    end

    assert_redirected_to admin_site_customization_member_types_path
  end
end
