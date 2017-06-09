class CanCreateIssueController < ApplicationController
  def index
    if current_user.can_create_issue
      render_from(message: 'You can create more issues', status: :ok)
    else
      render_from(message: 'You can\'t create more issues', status: :unauthorized)
    end
  end
end
