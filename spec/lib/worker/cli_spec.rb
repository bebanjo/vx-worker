require 'spec_helper'

describe Vx::Worker::CLI do
  let(:cli) { described_class.new }

  context "#once_timeout?" do
    context "without minimum hour minutes" do
      it "should be true when last_run_at greater then timeout" do
        last_run_at = Time.now - (2 * 60 + 1)
        expect(cli.once_timeout? last_run_at, nil).to be_true
      end

      it "should be false when last_run_at less then timeout" do
        last_run_at = Time.now - (2 * 60 - 1)
        expect(cli.once_timeout? last_run_at, nil).to be_false
      end
    end

    context "with minimum hour minutes" do
      let(:min_minutes) { 45 }
      let(:cli)         { described_class.new once_min: min_minutes }
      let(:tm)          { Time.new(2008, 9, 1, 10, 0, 0) }

      before(:each) do
        Timecop.travel(tm)
      end

      after(:each) do
        Timecop.return
      end

      context "when last_run_at less then timeout" do
        let(:last_run_at) { tm - (2 * 60 - 1) }

        it "should be false when worked time greater then minimin hour minutes" do
          started_at = tm - (45 * 60 + 1)
          expect(cli.once_timeout? last_run_at, started_at).to be_false
        end
      end

      context "when last_run_at greater then timeout" do
        let(:last_run_at) { tm - (2 * 60 + 1) }

        it "should be true when worked time greater then minimin hour minutes" do
          started_at = tm - (14 * 60)
          expect(cli.once_timeout? last_run_at, started_at).to be_true
        end

        it "should be true when remainder of worked time greater then minimin hour minutes" do
          started_at = tm - (74 * 60)
          expect(cli.once_timeout? last_run_at, started_at).to be_true
        end

        it "should be false when worked time less then minimin hour minutes" do
          started_at = tm - (16 * 60)
          expect(cli.once_timeout? last_run_at, started_at).to be_false
        end

        it "should be false when remainder worked time less then minimin hour minutes" do
          started_at = tm - (76 * 60)
          expect(cli.once_timeout? last_run_at, started_at).to be_false
        end

        context "and remainder greater then 55 minutes" do

          it "should be false when worked time greater then minimin hour minutes" do
            started_at = tm - (3 * 60)
            expect(cli.once_timeout? last_run_at, started_at).to be_false
          end

          it "should be false when remainder of worked time greater then minimin hour minutes" do
            started_at = tm - (3 * 60)
            expect(cli.once_timeout? last_run_at, started_at).to be_false
          end
        end
      end
    end
  end

end
