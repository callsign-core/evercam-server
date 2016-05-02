defmodule AccessRight do
  use EvercamMedia.Web, :model
  alias EvercamMedia.Repo
  import Ecto.Query

  schema "access_rights" do
    belongs_to :access_token, AccessToken, foreign_key: :token_id
    belongs_to :camera, Camera, foreign_key: :camera_id
    belongs_to :grantor, User, foreign_key: :grantor_id
    belongs_to :snapshot, Snapshot, foreign_key: :snapshot_id
    belongs_to :account, User, foreign_key: :account_id

    field :right, :string
    field :status, :integer
    field :scope, :string

    field :updated_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :created_at, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  def allows?(requester, resource, right, scope) do
    token = AccessToken.active_token_for(requester.id)

    access_rights =
      AccessRight
      |> where([ar], ar.token_id == ^token.id)
      |> where(account_id: ^resource.id)
      |> where(status: 1)
      |> where(right: ^right)
      |> where(scope: ^scope)
      |> Repo.all

    case access_rights do
      nil -> false
      [] -> false
      _ -> true
    end
  end
end
