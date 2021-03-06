module Xattachable
  extend ActiveSupport::Concern
  def fetch_picture(picture = nil)
    @picture = if picture
                 parse_image_data picture
               elsif params[:picture]
                 parse_image_data params[:picture]
               elsif params[:image]
                 parse_image_data params[:image]
               end
  end

  def parse_image_data(image_data)
    content_type = image_data[:content_type]
    image_file = Paperclip.io_adapters.for("data:#{content_type};base64,#{image_data[:content]}")
    image_file.original_filename = image_data[:filename]
    image_file
  rescue => e
    render json: { message: 'Invalid attachment', error: e.message }, status: :bad_request
    nil
  end
end