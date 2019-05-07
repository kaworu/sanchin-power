# frozen_string_literal: true

describe 'users search end-point', :transaction do
  before(:each) do
    creation = create_user build(:user, :with_credentials)
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  before(:each) do
    # XXX: once the search may use params we will have to craft the list
    # (e.g. gender split etc.)
    users = Array.new(10) do
      result = create_user build(:user)
      expect(result).to be_success
      result.value!
    end
    @all_users = [@current_user] + users # FIXME: ugly
  end

  it 'should return all users' do
    header 'authorization', "Bearer #{@token}"
    get '/api/v1/users'
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('application/json')
    expect(json_body).to eq(hiphop(@all_users))
  end

  it 'should not return password'
end
