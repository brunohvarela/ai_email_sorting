defmodule AiEmailSorting.EmailSummariesTest do
  use AiEmailSorting.DataCase

  alias AiEmailSorting.EmailSummaries

  describe "email_summaries" do
    alias AiEmailSorting.EmailSummaries.EmailSummary

    import AiEmailSorting.CategoriesFixtures
    import AiEmailSorting.EmailSummariesFixtures

    @invalid_attrs %{from: nil, subject: nil, summary: nil, category_id: nil}

    test "list_email_summaries/0 returns all email summaries" do
      email_summary = email_summary_fixture()
      assert EmailSummaries.list_email_summaries() == [email_summary]
    end

    test "get_email_summary!/1 returns the email summary with given id" do
      email_summary = email_summary_fixture()
      assert EmailSummaries.get_email_summary!(email_summary.id) == email_summary
    end

    test "create_email_summary/1 with valid data creates an email summary" do
      category = category_fixture()

      valid_attrs = %{
        from: "sender@example.com",
        subject: "some subject",
        summary: "some summary",
        category_id: category.id
      }

      assert {:ok, %EmailSummary{} = email_summary} = EmailSummaries.create_email_summary(valid_attrs)
      assert email_summary.from == "sender@example.com"
      assert email_summary.subject == "some subject"
      assert email_summary.summary == "some summary"
      assert email_summary.category_id == category.id
    end

    test "create_email_summary/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = EmailSummaries.create_email_summary(@invalid_attrs)
    end

    test "update_email_summary/2 with valid data updates the email summary" do
      email_summary = email_summary_fixture()

      update_attrs = %{
        from: "updated@example.com",
        subject: "updated subject",
        summary: "updated summary"
      }

      assert {:ok, %EmailSummary{} = updated_email_summary} =
               EmailSummaries.update_email_summary(email_summary, update_attrs)

      assert updated_email_summary.from == "updated@example.com"
      assert updated_email_summary.subject == "updated subject"
      assert updated_email_summary.summary == "updated summary"
      assert updated_email_summary.category_id == email_summary.category_id
    end

    test "update_email_summary/2 with invalid data returns error changeset" do
      email_summary = email_summary_fixture()

      assert {:error, %Ecto.Changeset{}} =
               EmailSummaries.update_email_summary(email_summary, @invalid_attrs)

      assert email_summary == EmailSummaries.get_email_summary!(email_summary.id)
    end

    test "delete_email_summary/1 deletes the email summary" do
      email_summary = email_summary_fixture()
      assert {:ok, %EmailSummary{}} = EmailSummaries.delete_email_summary(email_summary)

      assert_raise Ecto.NoResultsError, fn ->
        EmailSummaries.get_email_summary!(email_summary.id)
      end
    end

    test "change_email_summary/1 returns an email summary changeset" do
      email_summary = email_summary_fixture()
      assert %Ecto.Changeset{} = EmailSummaries.change_email_summary(email_summary)
    end
  end
end
