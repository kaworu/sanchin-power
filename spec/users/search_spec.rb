# frozen_string_literal: true

describe 'users search end-point', :transaction do
  before(:each) do
    # XXX: once the search may use params we will have to craft the list
    # (e.g. gender split etc.)
    @users = Array.new(10) do
      result = create_user.call build(:user)
      expect(result).to be_success
      result.value!
    end
  end

  it 'should return all users' do
    get '/api/v1/users'
    expect(last_response.status).to eq(200)
    expect(last_response.content_type).to eq('application/json')
    expect(json_body).to eq(hiphop(@users))
  end
  context 'with an up-to-date resource' do
    it 'should return 304 Not Modified' do
      latest = @users.map(&:updated_at).max
      header 'if-modified-since', latest.httpdate
      get '/api/v1/users'
      expect(last_response.status).to eq(304)
      expect(last_response.body).to be_empty
    end
  end
  context 'with a stale resource' do
    it 'should return all users' do
      latest = @users.map(&:updated_at).max
      header 'if-modified-since', (latest - 1).httpdate
      get '/api/v1/users'
      expect(last_response.status).to eq(200)
      expect(last_response.content_type).to eq('application/json')
      expect(json_body).to eq(hiphop(@users))
    end
  end
end
