package main

import (
	"context"
	"flag"
	"fmt"
	"testing"
	"time"

	"github.com/cucumber/godog"
	tide "tidewatch/src"
)

type tideState struct {
	table []tide.Reading
	got   tide.Reading
	err   error
}

func (s *tideState) theTideTableFor(_ string) error {
	t, err := tide.LoadTides("data/tides.json")
	s.table = t
	return err
}

func (s *tideState) iAskForTheNextHighTideAfter(ts string) error {
	after, err := time.Parse(time.RFC3339, ts)
	if err != nil {
		return err
	}
	s.got, s.err = tide.NextHigh(s.table, after)
	return nil
}

func (s *tideState) thePredictedHighTideIsAtWithHeight(ts string, h float64) error {
	if s.err != nil {
		return s.err
	}
	want, err := time.Parse(time.RFC3339, ts)
	if err != nil {
		return err
	}
	if !s.got.Time.Equal(want) {
		return fmt.Errorf("time: want %s, got %s", want, s.got.Time)
	}
	if s.got.Height != h {
		return fmt.Errorf("height: want %v, got %v", h, s.got.Height)
	}
	return nil
}

func (s *tideState) thePredictionFailsWith(msg string) error {
	if s.err == nil {
		return fmt.Errorf("want failure %q, got a prediction", msg)
	}
	if s.err.Error() != msg {
		return fmt.Errorf("want %q, got %q", msg, s.err.Error())
	}
	return nil
}

func InitializeScenario(sc *godog.ScenarioContext) {
	s := &tideState{}
	sc.Before(func(ctx context.Context, _ *godog.Scenario) (context.Context, error) {
		*s = tideState{}
		return ctx, nil
	})
	sc.Given(`^the tide table for (.+)$`, s.theTideTableFor)
	sc.When(`^I ask for the next high tide after "([^"]*)"$`, s.iAskForTheNextHighTideAfter)
	sc.Then(`^the predicted high tide is at "([^"]*)" with height (\d+\.?\d*)$`, s.thePredictedHighTideIsAtWithHeight)
	sc.Then(`^the prediction fails with "([^"]*)"$`, s.thePredictionFailsWith)
}

var opts = godog.Options{Format: "pretty", Paths: []string{"features"}}

func init() {
	godog.BindFlags("godog.", flag.CommandLine, &opts)
}

func TestFeatures(t *testing.T) {
	o := opts
	o.TestingT = t
	suite := godog.TestSuite{ScenarioInitializer: InitializeScenario, Options: &o}
	if suite.Run() != 0 {
		t.Fatal("non-zero status returned, failed to run feature tests")
	}
}
