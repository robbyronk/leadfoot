defmodule Leadfoot.Leaderboard do
  @moduledoc """
  The Leaderboard context.
  """

  import Ecto.Query, warn: false

  alias Leadfoot.Leaderboard.LapTime
  alias Leadfoot.Repo

  @doc """
  Returns the list of lap_times.

  ## Examples

      iex> list_lap_times()
      [%LapTime{}, ...]

  """
  def list_lap_times do
    Repo.all(LapTime)
  end

  @doc """
  Gets a single lap_time.

  Raises `Ecto.NoResultsError` if the Lap time does not exist.

  ## Examples

      iex> get_lap_time!(123)
      %LapTime{}

      iex> get_lap_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lap_time!(id), do: Repo.get!(LapTime, id)

  @doc """
  Creates a lap_time.

  ## Examples

      iex> create_lap_time(%{field: value})
      {:ok, %LapTime{}}

      iex> create_lap_time(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lap_time(attrs \\ %{}) do
    %LapTime{}
    |> LapTime.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lap_time.

  ## Examples

      iex> update_lap_time(lap_time, %{field: new_value})
      {:ok, %LapTime{}}

      iex> update_lap_time(lap_time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lap_time(%LapTime{} = lap_time, attrs) do
    lap_time
    |> LapTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lap_time.

  ## Examples

      iex> delete_lap_time(lap_time)
      {:ok, %LapTime{}}

      iex> delete_lap_time(lap_time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lap_time(%LapTime{} = lap_time) do
    Repo.delete(lap_time)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lap_time changes.

  ## Examples

      iex> change_lap_time(lap_time)
      %Ecto.Changeset{data: %LapTime{}}

  """
  def change_lap_time(%LapTime{} = lap_time, attrs \\ %{}) do
    LapTime.changeset(lap_time, attrs)
  end
end
