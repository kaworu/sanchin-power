# frozen_string_literal: true

describe 'users find end-point', :transaction do
  before(:each) do
    creation = create_user build(:user, :with_credentials)
    expect(creation).to be_success
    @current_user = creation.value!
    encoding = tokenize @current_user
    expect(encoding).to be_success
    @token = encoding.value!
  end

  context 'when given malformed id' do
    it 'should return 404 Not Found' do
      header 'authorization', "Bearer #{@token}"
      get '/api/v1/users/foo'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      header 'authorization', "Bearer #{@token}"
      get "/api/v1/users/#{SecureRandom.uuid}"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'with an up-to-date resource' do
    it 'should return 304 Not Modified' do
      header 'authorization', "Bearer #{@token}"
      header 'if-none-match', etag(@current_user.version)
      get "/api/v1/users/#{@current_user.id}"
      expect(last_response.status).to eq(304)
      expect(last_response.body).to be_empty
    end
  end

  context 'with a stale resource' do
    it 'should return the matching user' do
      header 'authorization', "Bearer #{@token}"
      header 'if-none-match', SecureRandom.uuid
      get "/api/v1/users/#{@current_user.id}"
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to eq(hiphop(@current_user))
    end
  end

  it 'should return the matching user' do
    header 'authorization', "Bearer #{@token}"
    get "/api/v1/users/#{@current_user.id}"
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('application/json')
    expect(json_body).to eq(hiphop(@current_user))
  end
end
