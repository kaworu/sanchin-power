# frozen_string_literal: true

describe 'users destruction end-point', :transaction do
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
      delete '/api/v1/users/foo'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'when given an invalid id' do
    it 'should return 404 Not Found' do
      header 'authorization', "Bearer #{@token}"
      delete "/api/v1/users/#{SecureRandom.uuid}"
      expect(last_response.status).to eq(404)
      expect(last_response.body).to be_empty
    end
  end

  context 'with a stale resource' do
    it 'should return 412 Precondition Failed' do
      header 'authorization', "Bearer #{@token}"
      header 'if-match', etag(SecureRandom.uuid)
      delete "/api/v1/users/#{@current_user.id}"
      expect(last_response.status).to eq(412)
      expect(last_response.body).to be_empty
    end
  end

  context 'without HTTP_IF_MATCH' do
    it 'should return 428 Precondition Required' do
      header 'authorization', "Bearer #{@token}"
      delete "/api/v1/users/#{@current_user.id}"
      expect(last_response.status).to eq(428)
      expect(last_response.body).to be_empty
    end
  end

  it 'should delete the matching user' do
      header 'authorization', "Bearer #{@token}"
    header 'if-match', etag(@current_user.version)
    delete "/api/v1/users/#{@current_user.id}"
    expect(last_response.status).to eq(204)
    expect(last_response.body).to be_empty
    expect(find_user(@current_user.id)).to be_failure
  end
end
