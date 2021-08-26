shared_examples "returns http success" do
  it 'レスポンスが正しいこと' do
    subject
    expect(response).to have_http_status(:success)
  end
end

shared_examples "returns http bad request" do
  it 'レスポンスが正しいこと' do
    subject
    expect(response).to have_http_status(:bad_request)
  end
end