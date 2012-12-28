/*
 * Copyright (C) 2007 by
 * 
 * 	Xuan-Hieu Phan
 *	hieuxuan@ecei.tohoku.ac.jp or pxhieu@gmail.com
 * 	Graduate School of Information Sciences
 * 	Tohoku University
 *
 * GibbsLDA++ is a free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version.
 *
 * GibbsLDA++ is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License * along with GibbsLDA++; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA.
 */

/* 
 * References:
 * + The Java code of Gregor Heinrich (gregor@arbylon.net)
 *   http://www.arbylon.net/projects/LdaGibbsSampler.java
 * + "Parameter estimation for text analysis" by Gregor Heinrich
 *   http://www.arbylon.net/publications/text-est.pdf
 */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <itpp/itbase.h>
#include "constants.h"
#include "strtokenizer.h"
#include "utils.h"
#include "dataset.h"
#include "model.h"

using namespace std;

model::~model() {
    if (p) {
	delete p;
    }

    if (ptrndata) {
	delete ptrndata;
    }
    
    if (pnewdata) {
	delete pnewdata;
    }

    if (z) {
	for (int m = 0; m < M; m++) {
	    if (z[m]) {
		delete z[m];
	    }
	}
    }
    
    if (nw) {
	for (int w = 0; w < V; w++) {
	    if (nw[w]) {
		delete nw[w];
	    }
	}
    }

    if (nd) {
	for (int m = 0; m < M; m++) {
	    if (nd[m]) {
		delete nd[m];
	    }
	}
    } 
    
    if (nwsum) {
	delete nwsum;
    }   
    
    if (ndsum) {
	delete ndsum;
    }
    
    if (theta) {
	for (int m = 0; m < M; m++) {
	    if (theta[m]) {
		delete theta[m];
	    }
	}
    }
    
    if (phi) {
	for (int k = 0; k < K; k++) {
	    if (phi[k]) {
		delete phi[k];
	    }
	}
    }

    // only for inference
    if (newz) {
	for (int m = 0; m < newM; m++) {
	    if (newz[m]) {
		delete newz[m];
	    }
	}
    }
    
    if (newnw) {
	for (int w = 0; w < newV; w++) {
	    if (newnw[w]) {
		delete newnw[w];
	    }
	}
    }

    if (newnd) {
	for (int m = 0; m < newM; m++) {
	    if (newnd[m]) {
		delete newnd[m];
	    }
	}
    } 
    
    if (newnwsum) {
	delete newnwsum;
    }   
    
    if (newndsum) {
	delete newndsum;
    }
    
    if (newtheta) {
	for (int m = 0; m < newM; m++) {
	    if (newtheta[m]) {
		delete newtheta[m];
	    }
	}
    }
    
    if (newphi) {
	for (int k = 0; k < K; k++) {
	    if (newphi[k]) {
		delete newphi[k];
	    }
	}
    }
}

void model::set_default_values() {
    wordmapfile = "wordmap.txt";
    trainlogfile = "trainlog.txt";
    tassign_suffix = ".tassign";
    theta_suffix = ".theta";
    phi_suffix = ".phi";
    others_suffix = ".others";
    twords_suffix = ".twords";
    
    dir = "./";
    dfile = "trndocs.dat";
    model_name = "model-final";    
    model_status = MODEL_STATUS_UNKNOWN;
    
    ptrndata = NULL;
    pnewdata = NULL;
    
    M = 0;
    V = 0;
    K = 100;
    alpha = 50.0 / K;
    beta = 0.1;
    niters = 2000;
    liter = 0;
    savestep = 200;    
    twords = 0;
    withrawstrs = 0;
    
    p = NULL;
    z = NULL;
    nw = NULL;
    nd = NULL;
    nwsum = NULL;
    ndsum = NULL;
    theta = NULL;
    phi = NULL;
    
    newM = 0;
    newV = 0;
    newz = NULL;
    newnw = NULL;
    newnd = NULL;
    newnwsum = NULL;
    newndsum = NULL;
    newtheta = NULL;
    newphi = NULL;

    // for discLda
    sigma = 0.1;  // fixed
    eta = NULL; // focused on mean para
    bias = 0;
}

int model::parse_args(int argc, char ** argv) {
    return utils::parse_args(argc, argv, this);
}

int model::init(int argc, char ** argv, int dicnum, int docnum, \
        int headernum) {
    // call parse_args
    if (parse_args(argc, argv)) {
	return 1;
    }
    
    if (model_status == MODEL_STATUS_EST) {
	// estimating the model from scratch
	if (init_est(dicnum, docnum, headernum)) {
	    return 1;
	}
	
    } else if (model_status == MODEL_STATUS_ESTC) {
	// estimating the model from a previously estimated one
	if (init_estc()) {
	    return 1;
	}
	
    } else if (model_status == MODEL_STATUS_INF) {
	// do inference
	if (init_inf(dicnum, docnum, headernum)) {
	    return 1;
	}
    }
    return 0;
}

int model::load_model(string model_name) {
    int i, j;
    
    string filename = dir + model_name + tassign_suffix;
    FILE * fin = fopen(filename.c_str(), "r");
    if (!fin) {
	printf("Cannot open file %s to load model!\n", filename.c_str());
	return 1;
    }
    
    char buff[BUFF_SIZE_LONG];
    string line;

    // allocate memory for z and ptrndata
    z = new int*[M];
    ptrndata = new dataset(M);
    ptrndata->V = V;

    for (i = 0; i < M; i++) {
	char * pointer = fgets(buff, BUFF_SIZE_LONG, fin);
	if (!pointer) {
	    printf("Invalid word-topic assignment file, check the number of docs!\n");
	    return 1;
	}
	
	line = buff;
	strtokenizer strtok(line, " \t\r\n");
	int length = strtok.count_tokens();
	
	vector<int> words;
	vector<int> topics;
	for (j = 0; j < length; j++) {
	    string token = strtok.token(j);
    
	    strtokenizer tok(token, ":");
	    if (tok.count_tokens() != 2) {
		printf("Invalid word-topic assignment line!\n");
		return 1;
	    }
	    
	    words.push_back(atoi(tok.token(0).c_str()));
	    topics.push_back(atoi(tok.token(1).c_str()));
	}
	
	// allocate and add new document to the corpus
	document * pdoc = new document(words);
	ptrndata->add_doc(pdoc, i);
	
	// assign values for z
	z[i] = new int[topics.size()];
	for (j = 0; j < topics.size(); j++) {
	    z[i][j] = topics[j];
	}
    }   
    
    fclose(fin);
    
    return 0;
}

int model::save_model(string model_name) {
    if (save_model_tassign(dir + model_name + tassign_suffix)) {
	return 1;
    }
    
    if (save_model_others(dir + model_name + others_suffix)) {
	return 1;
    }
    
    if (save_model_theta(dir + model_name + theta_suffix)) {
	return 1;
    }
    
    if (save_model_phi(dir + model_name + phi_suffix)) {
	return 1;
    }
    
    if (twords > 0) {
	if (save_model_twords(dir + model_name + twords_suffix)) {
	    return 1;
	}
    }
    
    return 0;
}

int model::save_model(string phifile, string thetafile, string tassignfile,\
        string otherparafile){
    if (save_model_tassign(tassignfile + tassign_suffix)) {
        return 1; 
    }
    if (save_model_theta(thetafile)){
        return 1;
    }

    if (save_model_phi(phifile)){
        return 1;
    }
    
    if (save_model_others(otherparafile + others_suffix)) {
	    return 1;
    }
}


int model::save_model_tassign(string filename) {
    int i, j;
    
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }

    // wirte docs with topic assignments for words
    for (i = 0; i < ptrndata->M; i++) {    
	for (j = 0; j < ptrndata->docs[i]->length; j++) {
	    fprintf(fout, "%d:%d ", ptrndata->docs[i]->words[j], z[i][j]);
	}
	fprintf(fout, "\n");
    }

    fclose(fout);
    
    return 0;
}

int model::save_model_theta(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    for (int i = 0; i < M; i++) {
	for (int j = 0; j < K; j++) {
	    fprintf(fout, "%f ", theta[i][j]);
	}
	fprintf(fout, "\n");
    }
    
    fclose(fout);
    
    return 0;
}

int model::save_model_phi(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    for (int i = 0; i < K; i++) {
	for (int j = 0; j < V; j++) {
	    fprintf(fout, "%f ", phi[i][j]);
	}
	fprintf(fout, "\n");
    }
    
    fclose(fout);    
    
    return 0;
}

int model::save_model_others(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }

    fprintf(fout, "alpha=%f\n", alpha);
    fprintf(fout, "beta=%f\n", beta);
    fprintf(fout, "ntopics=%d\n", K);
    fprintf(fout, "ndocs=%d\n", M);
    fprintf(fout, "nwords=%d\n", V);
    fprintf(fout, "liter=%d\n", liter);
    
    fclose(fout);    
    
    return 0;
}

int model::save_model_twords(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    if (twords > V) {
	twords = V;
    }
    mapid2word::iterator it;
    
    for (int k = 0; k < K; k++) {
	vector<pair<int, double> > words_probs;
	pair<int, double> word_prob;
	for (int w = 0; w < V; w++) {
	    word_prob.first = w;
	    word_prob.second = phi[k][w];
	    words_probs.push_back(word_prob);
	}
    
        // quick sort to sort word-topic probability
	utils::quicksort(words_probs, 0, words_probs.size() - 1);
	
	fprintf(fout, "Topic %dth:\n", k);
	for (int i = 0; i < twords; i++) {
	    it = id2word.find(words_probs[i].first);
	    if (it != id2word.end()) {
		fprintf(fout, "\t%s   %f\n", (it->second).c_str(), words_probs[i].second);
	    }
	}
    }
    
    fclose(fout);    
    
    return 0;    
}

int model::save_inf_model(string model_name) {
    if (save_inf_model_tassign(dir + model_name + tassign_suffix)) {
	return 1;
    }
    
    if (save_inf_model_others(dir + model_name + others_suffix)) {
	return 1;
    }
    
    if (save_inf_model_newtheta(dir + model_name + theta_suffix)) {
	return 1;
    }
    
    if (save_inf_model_newphi(dir + model_name + phi_suffix)) {
	return 1;
    }

    if (twords > 0) {
	if (save_inf_model_twords(dir + model_name + twords_suffix)) {
	    return 1;
	}
    }
    
    return 0;
}

int model::save_inf_model(string featurefile_phi, \
        string featurefile_theta, string tassignfile){

    if (save_inf_model_tassign(tassignfile + \
                tassign_suffix)) {
	    return 1;
    }

    if (save_inf_model_newtheta(featurefile_theta)) {
	    return 1;
    }
    
    if (save_inf_model_newphi(featurefile_phi)) {
	    return 1;
    }

    return 0;
}

int model::save_inf_model_tassign(string filename) {
    int i, j;
    
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }

    // wirte docs with topic assignments for words
    for (i = 0; i < pnewdata->M; i++) {    
	for (j = 0; j < pnewdata->docs[i]->length; j++) {
	    fprintf(fout, "%d:%d ", pnewdata->docs[i]->words[j], newz[i][j]);
	}
	fprintf(fout, "\n");
    }

    fclose(fout);
    
    return 0;
}

int model::save_inf_model_newtheta(string filename) {
    int i, j;

    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    for (i = 0; i < newM; i++) {
	for (j = 0; j < K; j++) {
	    fprintf(fout, "%f ", newtheta[i][j]);
	}
	fprintf(fout, "\n");
    }
    
    fclose(fout);
    
    return 0;
}

int model::save_inf_model_newphi(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    for (int i = 0; i < K; i++) {
	for (int j = 0; j < newV; j++) {
	    fprintf(fout, "%f ", newphi[i][j]);
	}
	fprintf(fout, "\n");
    }
    
    fclose(fout);    
    
    return 0;
}

int model::save_inf_model_others(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }

    fprintf(fout, "alpha=%f\n", alpha);
    fprintf(fout, "beta=%f\n", beta);
    fprintf(fout, "ntopics=%d\n", K);
    fprintf(fout, "ndocs=%d\n", newM);
    fprintf(fout, "nwords=%d\n", newV);
    fprintf(fout, "liter=%d\n", inf_liter);
    
    fclose(fout);    
    
    return 0;
}

int model::save_inf_model_twords(string filename) {
    FILE * fout = fopen(filename.c_str(), "w");
    if (!fout) {
	printf("Cannot open file %s to save!\n", filename.c_str());
	return 1;
    }
    
    if (twords > newV) {
	twords = newV;
    }
    mapid2word::iterator it;
    map<int, int>::iterator _it;
    
    for (int k = 0; k < K; k++) {
	vector<pair<int, double> > words_probs;
	pair<int, double> word_prob;
	for (int w = 0; w < newV; w++) {
	    word_prob.first = w;
	    word_prob.second = newphi[k][w];
	    words_probs.push_back(word_prob);
	}
    
        // quick sort to sort word-topic probability
	utils::quicksort(words_probs, 0, words_probs.size() - 1);
	
	fprintf(fout, "Topic %dth:\n", k);
	for (int i = 0; i < twords; i++) {
	    _it = pnewdata->_id2id.find(words_probs[i].first);
	    if (_it == pnewdata->_id2id.end()) {
		continue;
	    }
	    it = id2word.find(_it->second);
	    if (it != id2word.end()) {
		fprintf(fout, "\t%s   %f\n", (it->second).c_str(), words_probs[i].second);
	    }
	}
    }
    
    fclose(fout);    
    
    return 0;    
}


int model::init_est(int dicnum, int docnum, int headernum) {
    int m, n, w, k;

    p = new double[K];

    // + read training data
    ptrndata = new dataset;
    //if (ptrndata->read_trndata(dir + dfile, dir + wordmapfile)) {
    //    printf("Fail to read training data!\n");
    //    return 1;
    //}
    if (ptrndata->read_nv_data(dir + dfile, dicnum, docnum, headernum)){
        printf("Fail to read training data!\n");
        return 1;
    }
		
    // + allocate memory and assign values for variables
    M = ptrndata->M;
    V = ptrndata->V;
    Totalwords = ptrndata->Totalwords;
    
    // K: from command line or default value
    // alpha, beta: from command line or default values
    // niters, savestep: from command line or default values

    nw = new int*[V];
    for (w = 0; w < V; w++) {
        nw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    nw[w][k] = 0;
        }
    }
	
    mulnw = new int*[V];
    for (w = 0; w < V; w++) {
        mulnw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    mulnw[w][k] = 0;
        }
    }

    nd = new int*[M];
    for (m = 0; m < M; m++) {
        nd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    nd[m][k] = 0;
        }
    }
    
    mulnd = new int*[M];
    for (m = 0; m < M; m++) {
        mulnd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    mulnd[m][k] = 0;
        }
    }
    
    nwsum = new int[K];
    for (k = 0; k < K; k++) {
	    nwsum[k] = 0;
    }

    mulnwsum = new int[K];
    for (k = 0; k < K; k++) {
	    mulnwsum[k] = 0;
    }
    
    ndsum = new int[M];
    for (m = 0; m < M; m++) {
	    ndsum[m] = 0;
    }
    
    mulndsum = new int[M];
    for (m = 0; m < M; m++) {
	    mulndsum[m] = 0;
    }
    
    // for discLda
    eta = new double[K];
    gau_prob = new double[K];
    for (k = 0; k < K; k++){
        eta[k] = 0;
        gau_prob[k] = 0;
    }

    srandom(time(0)); // initialize for random number generation
    z = new int*[M];
    for (m = 0; m < ptrndata->M; m++) {
	int N = ptrndata->docs[m]->length;
	z[m] = new int[N];
	
        // initialize for z
        for (n = 0; n < N; n++) {
    	    int topic = (int)(((double)random() / RAND_MAX) * K);
    	    z[m][n] = topic;
    	    
    	    // number of instances of word i assigned to topic j
    	    nw[ptrndata->docs[m]->words[n]][topic] += 1;
    	    // number of words in document i assigned to topic j
    	    nd[m][topic] += 1;
    	    // total number of words assigned to topic j
    	    nwsum[topic] += 1;
        } 
        // total number of words in document i
        ndsum[m] = N;      
    }
    
    theta = new double*[M];
    for (m = 0; m < M; m++) {
        theta[m] = new double[K];
    }
	
    phi = new double*[K];
    for (k = 0; k < K; k++) {
        phi[k] = new double[V];
    }    
    
    return 0;
}

int model::init_estc() {
    // estimating the model from a previously estimated one
    int m, n, w, k;

    p = new double[K];

    // load moel, i.e., read z and ptrndata
    if (load_model(model_name)) {
	printf("Fail to load word-topic assignmetn file of the model!\n");
	return 1;
    }

    nw = new int*[V];
    for (w = 0; w < V; w++) {
        nw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    nw[w][k] = 0;
        }
    }
	
    nd = new int*[M];
    for (m = 0; m < M; m++) {
        nd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    nd[m][k] = 0;
        }
    }
	
    nwsum = new int[K];
    for (k = 0; k < K; k++) {
	nwsum[k] = 0;
    }
    
    ndsum = new int[M];
    for (m = 0; m < M; m++) {
	ndsum[m] = 0;
    }

    for (m = 0; m < ptrndata->M; m++) {
	int N = ptrndata->docs[m]->length;

	// assign values for nw, nd, nwsum, and ndsum	
        for (n = 0; n < N; n++) {
    	    int w = ptrndata->docs[m]->words[n];
    	    int topic = z[m][n];
    	    
    	    // number of instances of word i assigned to topic j
    	    nw[w][topic] += 1;
    	    // number of words in document i assigned to topic j
    	    nd[m][topic] += 1;
    	    // total number of words assigned to topic j
    	    nwsum[topic] += 1;
        } 
        // total number of words in document i
        ndsum[m] = N;      
    }
	
    theta = new double*[M];
    for (m = 0; m < M; m++) {
        theta[m] = new double[K];
    }
	
    phi = new double*[K];
    for (k = 0; k < K; k++) {
        phi[k] = new double[V];
    }    

    return 0;        
}

void model::estimate() {
    if (twords > 0) {
	// print out top words per topic
	dataset::read_wordmap(dir + wordmapfile, &id2word);
    }

    printf("Sampling %d iterations!\n", niters);

    double lik_biarray[2];
    float perplexity = 0.0;
    int last_iter = liter;
    time_t st_time, cur_time;
    
    pre_mle_learn();
    st_time = time(NULL);
    for (liter = last_iter + 1; liter <= niters + last_iter; liter++) {
        // similar to E-step, use Gibbs Sampling
        int inner_iter = 300;
        int start_iter = 250, interval = 5;
        
        for (int e_iter = 0; e_iter < inner_iter; e_iter++){     
            // for all z_i
	        for (int m = 0; m < M; m++) {
	            for (int n = 0; n < ptrndata->docs[m]->length; n++) {
		            // (z_i = z[m][n])
		            // sample from p(z_i|z_-i, w)
		            int topic = sampling(m, n);
		            z[m][n] = topic;
	            }
	        }
            // collect
            if (e_iter >= start_iter && (e_iter % interval == 0)){
                for (int v = 0; v < V; v++)
                    for (int k = 0; k < K; k++){
                        mulnw[v][k] += nw[v][k];
                        mulnwsum[k] += nw[v][k];
                    }
                for (int m = 0; m < M; m++)
                    for (int k = 0; k < K; k++){
                        mulnd[m][k] += nd[m][k];
                        mulndsum[m] += nd[m][k];
                    }
            }
        }

        // similar to M-step, use MLE with L2-regularization 
        //   derived from Gaussian represenation.
        printf("Linear regression weight: ");
        mle_learn();
        
        // compute log-likelihood and perplexity
        cur_time = time(NULL);
	    printf("Iteration = %d, time cost = %s,", liter, utils::rtime(cur_time - st_time));
        compute_loglikhood(lik_biarray, "train");
        perplexity = compute_perplexity(lik_biarray[0]);
        printf("Corpus log-likilihood = %f, per-word log-likilihood = %f, perplexity = %f...\n",\
                lik_biarray[0], lik_biarray[1], perplexity);
	
        // reset
        /*memset(mulnwsum, 0, sizeof(int)*K);
        memset(mulndsum, 0, sizeof(int)*M);
        for (int v = 0; v < V; v++)
            memset(mulnw[v], 0, sizeof(int)*K);
        for (int m = 0; m < M; m++)
            memset(mulnd[m], 0, sizeof(int)*K);*/
    }
    
    printf("Gibbs sampling completed!\n");
    printf("Saving the final model!\n");
    compute_theta();
    compute_phi();
    liter--;
    //save_model(utils::generate_model_name(-1));
    string phi_file = "./features/review.lda.gibbs++.phi.tr.txt";
    string theta_file = "./features/review.lda.gibbs++.theta.tr.txt";
    string tassign_file = "./features/review.lda.gibbs++.tr";
    string otherpara_file = "./features/review.lda.gibbs++.tr";
    save_model(phi_file, theta_file, tassign_file, \
            otherpara_file);
    
    // compute features
    string fea_file = "./features/review_features.lda.gibbs++.tr.txt";
    string eta_file = "./features/eta.txt";
    compute_train_feature(fea_file);
    save_eta(eta_file);
}

int model::sampling(int m, int n) {
    // remove z_i from the count variables
    int topic = z[m][n];
    int w = ptrndata->docs[m]->words[n];
    nw[w][topic] -= 1;
    nd[m][topic] -= 1;
    nwsum[topic] -= 1;
    ndsum[m] -= 1;

    double Vbeta = V * beta;
    double Kalpha = K * alpha;
   
    // for discLDA
    tr_gau_prob(m, w);
    // do multinomial sampling via cumulative method
    for (int k = 0; k < K; k++) {
	    p[k] = ((double)nw[w][k] + beta) / (nwsum[k] + Vbeta)
            * (nd[m][k] + alpha) / (ndsum[m] + Kalpha)
            * gau_prob[k];
        //if (m == 2025 && w == 11462){
        //    printf("%f:%f:%d:%d,", p[k], gau_prob[k], nw[w][k], nd[m][k]);
        //}
    }
    // cumulate multinomial parameters
    for (int k = 1; k < K; k++) {
	    p[k] += p[k - 1];
    }
    // scaled sample because of unnormalized p[]
    double u = ((double)random() / RAND_MAX) * p[K - 1];
    
    for (topic = 0; topic < K; topic++) {
	    if (p[topic] > u) {
	        break;
	    }
    }
    
    // add newly estimated z_i to count variables
    nw[w][topic] += 1;
    nd[m][topic] += 1;
    nwsum[topic] += 1;
    ndsum[m] += 1;    
    /*if (m == 2025 && w == 11462){
        printf("\nTopic: %d\n", topic);
        printf("Sample: %f\n", u);
        for (int i = 0; i < K; i++)
            printf("%d,%f,%f\n", nw[w][i], p[i], gau_prob[i]);
        printf("hahaha\n");
        getchar();
    }*/

    return topic;
}

void model::compute_theta() {
    for (int m = 0; m < M; m++) {
	for (int k = 0; k < K; k++) {
	    theta[m][k] = (nd[m][k] + alpha) / (ndsum[m] + K * alpha);
	}
    }
}

void model::compute_ns_theta(){
    for (int m = 0; m < M; m++) {
	    for (int k = 0; k < K; k++) {
            if (ndsum[m] != 0)
                //theta[m][k] = (double)nd[m][k] / ndsum[m];
                theta[m][k] = (double)mulnd[m][k] / mulndsum[m];
        }
    }
}

// Compute train features for training data (No smooth).
void model::compute_train_feature(string fea_file){
    
    double ** tr_fea = new double*[M];
    for (int m = 0; m < M; m++){
        tr_fea[m] = new double[K];
    }
    
    for (int m = 0; m < M; m++) {
        for (int k = 0; k < K; k++){
            //tr_fea[m][k] = (double)nd[m][k] / ndsum[m];
            //tr_fea[m][k] = (double)(nd[m][k] + alpha) / (ndsum[m] + K * alpha);
            tr_fea[m][k] = (double)mulnd[m][k] / mulndsum[m];
        }
    } 
    
    // output features
    FILE * fout = fopen(fea_file.c_str(), "w");
    if (!fout) {
	    printf("Cannot open file %s to save!\n", fea_file.c_str());
	    return ;
    }
    
    for (int i = 0; i < M; i++) {
	    for (int j = 0; j < K; j++) {
	        fprintf(fout, "%f ", tr_fea[i][j]);
	    }
	    fprintf(fout, "\n");
    }
    
    fclose(fout);
}

double ** model::compute_train_feature(){
    double ** tr_fea = new double*[M];
    for (int m = 0; m < M; m++){
        tr_fea[m] = new double[K];
    }
    
    for (int m = 0; m < M; m++) {
        for (int k = 0; k < K; k++){
            //tr_fea[m][k] = (double)(nd[m][k] + alpha) / (ndsum[m] + K * alpha);
            //tr_fea[m][k] = (double)nd[m][k] / ndsum[m];
            tr_fea[m][k] = (double)mulnd[m][k] / mulndsum[m];
            //printf("%d, %d, %f\n", mulnd[m][k], mulndsum[m], tr_fea[m][k]);
            //getchar();
        }
    }

    return tr_fea;
}

void model::compute_phi() {
    for (int k = 0; k < K; k++) {
	for (int w = 0; w < V; w++) {
	    phi[k][w] = (nw[w][k] + beta) / (nwsum[k] + V * beta);
	}
    }
}

void model::compute_ns_phi(){
    for (int k = 0; k < K; k++) {
	    for (int w = 0; w < V; w++) {
	        if (nwsum[k] != 0)
                //phi[k][w] = (double)nw[w][k] / nwsum[k];
                phi[k][w] = (double)mulnw[w][k] / mulnwsum[k];
	    }
    }

}

int model::init_inf(int dicnum, int docnum, int headernum) {
    // estimating the model from a previously estimated one
    int m, n, w, k;

    p = new double[K];

    // load moel, i.e., read z and ptrndata
    if (load_model(model_name)) {
	printf("Fail to load word-topic assignmetn file of the model!\n");
	return 1;
    }

    nw = new int*[V];
    for (w = 0; w < V; w++) {
        nw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    nw[w][k] = 0;
        }
    }
	
    // new records
    dict = new bool[V+1];   // may start from 1
    for (m = 0; m < V+1; m++)
        dict[m] = false;

    for (m = 0; m < ptrndata->M; m++){
        for (n = 0; n < ptrndata->docs[m]->length; n++){
            dict[ptrndata->docs[m]->words[n]] = true;
        }
    }
    
    nd = new int*[M];
    for (m = 0; m < M; m++) {
        nd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    nd[m][k] = 0;
        }
    }
	
    nwsum = new int[K];
    for (k = 0; k < K; k++) {
	nwsum[k] = 0;
    }
    
    
    ndsum = new int[M];
    for (m = 0; m < M; m++) {
	ndsum[m] = 0;
    }

    
    for (m = 0; m < ptrndata->M; m++) {
	int N = ptrndata->docs[m]->length;

	// assign values for nw, nd, nwsum, and ndsum	
        for (n = 0; n < N; n++) {
    	    int w = ptrndata->docs[m]->words[n];
    	    int topic = z[m][n];
    	    
    	    // number of instances of word i assigned to topic j
    	    nw[w][topic] += 1;
    	    // number of words in document i assigned to topic j
    	    nd[m][topic] += 1;
    	    // total number of words assigned to topic j
    	    nwsum[topic] += 1;
        } 
        // total number of words in document i
        ndsum[m] = N;      
    }
    
    // read new data for inference
    pnewdata = new dataset;
    if (withrawstrs) {
	if (pnewdata->read_newdata_withrawstrs(dir + dfile, dir + wordmapfile)) {
    	    printf("Fail to read new data!\n");
    	    return 1;
	}    
    } else {
	//if (pnewdata->read_newdata(dir + dfile, dir + wordmapfile)) {
    if (pnewdata->read_nv_newdata(dfile, dicnum, docnum, headernum)) {
    	    printf("Fail to read new data!\n");
    	    return 1;
	}    
    }
    newM = pnewdata->M;
    newV = pnewdata->V;
    Totalwords = pnewdata->Totalwords;
    
    newnw = new int*[newV];
    for (w = 0; w < newV; w++) {
        newnw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    newnw[w][k] = 0;
        }
    }
    
    mulnw = new int*[newV];
    for (w = 0; w < newV; w++) {
        mulnw[w] = new int[K];
        for (k = 0; k < K; k++) {
    	    mulnw[w][k] = 0;
        }
    }
	
    newnd = new int*[newM];
    for (m = 0; m < newM; m++) {
        newnd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    newnd[m][k] = 0;
        }
    }
    
    mulnd = new int*[newM];
    for (m = 0; m < M; m++) {
        mulnd[m] = new int[K];
        for (k = 0; k < K; k++) {
    	    mulnd[m][k] = 0;
        }
    }
	
    newnwsum = new int[K];
    for (k = 0; k < K; k++) {
	newnwsum[k] = 0;
    }
    
    mulnwsum = new int[K];
    for (k = 0; k < K; k++) {
	    mulnwsum[k] = 0;
    }
    
    newndsum = new int[newM];
    for (m = 0; m < newM; m++) {
	newndsum[m] = 0;
    }
    
    mulndsum = new int[newM];
    for (m = 0; m < newM; m++) {
	    mulndsum[m] = 0;
    }

    srandom(time(0)); // initialize for random number generation
    newz = new int*[newM];
    for (m = 0; m < pnewdata->M; m++) {
	int N = pnewdata->docs[m]->length;
	newz[m] = new int[N];

	// assign values for nw, nd, nwsum, and ndsum	
        for (n = 0; n < N; n++) {
    	    int w = pnewdata->docs[m]->words[n];
    	    int _w = pnewdata->_docs[m]->words[n];
    	    int topic = (int)(((double)random() / RAND_MAX) * K);
    	    newz[m][n] = topic;
    	    
    	    // number of instances of word i assigned to topic j
    	    newnw[_w][topic] += 1;
    	    // number of words in document i assigned to topic j
    	    newnd[m][topic] += 1;
    	    // total number of words assigned to topic j
    	    newnwsum[topic] += 1;
        } 
        // total number of words in document i
        newndsum[m] = N;      
    }    
    
    newtheta = new double*[newM];
    for (m = 0; m < newM; m++) {
        newtheta[m] = new double[K];
    }
	
    newphi = new double*[K];
    for (k = 0; k < K; k++) {
        newphi[k] = new double[newV];
    }    
  
    gau_prob = new double[K];
    for (k = 0; k < K; k++){
        gau_prob[k] = 0;
    }
    string eta_file = "./features/eta.txt";
    read_eta(eta_file);

    return 0;        
}

void model::inference() {
    //if (twords > 0) {
	// print out top words per topic
	//dataset::read_wordmap(dir + wordmapfile, &id2word);
    //}

    double lik_biarray[2];
    float perplexity = 0.0;
   
    int start_iter = 350, interval = 5;
    printf("Sampling %d iterations for inference!\n", niters);
    for (inf_liter = 1; inf_liter <= niters; inf_liter++) {
	    printf("Iteration %d...", inf_liter);
	    // for all newz_i
	    for (int m = 0; m < newM; m++) {
	        for (int n = 0; n < pnewdata->docs[m]->length; n++) {
		    // (newz_i = newz[m][n])
		    // sample from p(z_i|z_-i, w)
		    int topic = inf_sampling(m, n);
		    newz[m][n] = topic;
	        }
	    }
        // collect
        if (inf_liter >= start_iter && (inf_liter % interval == 0)){
            for (int v = 0; v < V; v++)
                for (int k = 0; k < K; k++){
                    mulnw[v][k] += newnw[v][k];
                    mulnwsum[k] += newnw[v][k];
                }
            for (int m = 0; m < newM; m++)
                for (int k = 0; k < K; k++){
                    mulnd[m][k] += newnd[m][k];
                    mulndsum[m] += newnd[m][k];
                }
        }
        compute_loglikhood(lik_biarray, "test");
        perplexity = compute_perplexity(lik_biarray[0]);
        printf("Corpus log-likilihood = %f, per-word log-likilihood = %f, perplexity = %f...\n",\
            lik_biarray[0], lik_biarray[1], perplexity);
    }
    
    printf("Gibbs sampling for inference completed!\n");
    printf("Saving the inference outputs!\n");
    compute_newtheta();
    compute_newphi();
    inf_liter--;
    
    string phi_file = "./features/review.lda.gibbs++.phi.tst.txt";
    string theta_file = "./features/review.lda.gibbs++.theta.tst.txt";
    string tassign_file = "./features/review.lda.gibbs++.tst";
    save_inf_model(phi_file, theta_file, tassign_file);

    // features
    string fea_file = "./features/review_features.lda.gibbs++.tst.txt";
    compute_test_feature(fea_file);
}

int model::inf_sampling(int m, int n) {
    // remove z_i from the count variables
    int topic = newz[m][n];
    int w = pnewdata->docs[m]->words[n];
    int _w = pnewdata->_docs[m]->words[n];
    newnw[_w][topic] -= 1;
    newnd[m][topic] -= 1;
    newnwsum[topic] -= 1;
    newndsum[m] -= 1;
    
    double Vbeta = V * beta;
    double Kalpha = K * alpha;
    // for discLDA
    //tst_gau_prob(m, w);   unknown rating, remove
    // do multinomial sampling via cumulative method
    for (int k = 0; k < K; k++) {
	p[k] = (nw[w][k] + newnw[_w][k] + beta) / (nwsum[k] + newnwsum[k] + Vbeta) *
		    (newnd[m][k] + alpha) / (newndsum[m] + Kalpha);
    }
    // cumulate multinomial parameters
    for (int k = 1; k < K; k++) {
	p[k] += p[k - 1];
    }
    // scaled sample because of unnormalized p[]
    double u = ((double)random() / RAND_MAX) * p[K - 1];
    
    for (topic = 0; topic < K; topic++) {
	
        if (p[topic] > u) {
	    break;
	}
    }
    
    // add newly estimated z_i to count variables
    newnw[_w][topic] += 1;
    newnd[m][topic] += 1;
    newnwsum[topic] += 1;
    newndsum[m] += 1;    
    
    return topic;
}

void model::compute_newtheta() {
    for (int m = 0; m < M; m++) {
	for (int k = 0; k < K; k++) {
	    newtheta[m][k] = (newnd[m][k] + alpha) / (newndsum[m] + K * alpha);
	}
    }
}

void model::compute_ns_newtheta() {
    for (int m = 0; m < M; m++) {
	for (int k = 0; k < K; k++) {
        if (newndsum[m] != 0)
	        newtheta[m][k] = (double)newnd[m][k] / newndsum[m];
	        //newtheta[m][k] = (double)mulnd[m][k] / mulndsum[m];
    }
    }
}

void model::compute_newphi() {
    for (int k = 0; k < K; k++) {
	for (int w = 0; w < V; w++) {
		newphi[k][w] = (nw[w][k] + newnw[w][k] + beta) / (nwsum[k] + newnwsum[k] + V * beta);
	}
    }
}

void model::compute_ns_newphi() {
    for (int k = 0; k < K; k++) {
	for (int w = 0; w < V; w++) {
		if ((nwsum[k] + newnwsum[k]) != 0)
            //newphi[k][w] = (double)(nw[w][k] + newnw[w][k]) / (nwsum[k] + newnwsum[k]);
            newphi[k][w] = (double)(nw[w][k] + newnw[w][k]) / (nwsum[k] + newnwsum[k]);
	}
    }
}

// Compute features for test data (No smooth).
void model::compute_test_feature(string fea_file){
    
    double ** tst_fea = new double*[M];
    for (int m = 0; m < M; m++){
        tst_fea[m] = new double[K];
    }
    
    for (int m = 0; m < M; m++) {
        for (int k = 0; k < K; k++){
            tst_fea[m][k] = (double)newnd[m][k] / newndsum[m];
            tst_fea[m][k] = (double)mulnd[m][k] / mulndsum[m];
            //tst_fea[m][k] = (double)(newnd[m][k] + alpha) / (newndsum[m] + K * alpha);
        }
    }

    // remove words not occur in training data
    /*for (int m = 0; m < M; m++) {
        for (int n = 0; n < pnewdata->docs[m]->length)
    }*/
    // output features
    FILE * fout = fopen(fea_file.c_str(), "w");
    if (!fout) {
	    printf("Cannot open file %s to save!\n", fea_file.c_str());
	    return ;
    }
    
    for (int i = 0; i < M; i++) {
	    for (int j = 0; j < K; j++) {
	        fprintf(fout, "%f ", tst_fea[i][j]);
	    }
	    fprintf(fout, "\n");
    }
    
    fclose(fout);
}

void model::compute_loglikhood(double * lik_biarray, string choice){
    // This method do two tasks: 1.compute the corpus log-likelihood;
    // 2.computer the per-word log-likelihood.

    int wd_idx;
    double word_lik = 0.0;
    
    lik_biarray[0] = 0.0;   // corpus log-likelihood

    if (choice == "train"){
        compute_ns_theta();
        compute_ns_phi();
        // document
        for (int m = 0; m < M; m++){
            //for (int idx = 0; idx < ptrndata/->docs[m]->length; idx++){    // Original version
            for (int idx = 0; idx < ptrndata->docs[m]->totalwdcnt; idx++){
                word_lik = 0.0;
                wd_idx = ptrndata->docs[m]->words[idx];
                for (int k = 0; k < K; k++){
                    word_lik += theta[m][k] * phi[k][wd_idx];
                }
                lik_biarray[0] += log(word_lik);
            }
            lik_biarray[0] += log((float)1/M);

        }
    }else if (choice == "test"){
        compute_ns_newtheta();
        compute_ns_newphi();
        // document
        for (int m = 0; m < M; m++){
            //for (int idx = 0; idx < ptrndata->docs[m]->length; idx++){    // Original version
            for (int idx = 0; idx < pnewdata->docs[m]->totalwdcnt; idx++){
                word_lik = 0.0;
                wd_idx = pnewdata->docs[m]->words[idx];
                for (int k = 0; k < K; k++){
                    word_lik += newtheta[m][k] * newphi[k][wd_idx];
                }
                lik_biarray[0] += log(word_lik);
            }
            lik_biarray[0] += log((float)1/M);
        }
    }else{
        printf("Choice is invaild.\n");
    }

    // per-word log-likelihood
    lik_biarray[1] = lik_biarray[0] / Totalwords;
}

float model::compute_perplexity(double log_lik){
    float perplexity = 0.0;
    
    perplexity = exp(-log_lik / Totalwords);
    return perplexity;
}

// for discLDA
void model::tr_gau_prob(int doc_id, int wd_id){
    double exp_sum = 0.0;
    double rate = ptrndata->docs[doc_id]->rate;
    
    // Method 1: sample based on the origin rating
    /*for (int i = 0; i < K; i++){
        gau_prob[i] = exp(-(pow(eta[i],2)*(1+2*nd[doc_id][i]))/pow(ndsum[doc_id],2)
                    + 2*rate*eta[i]/ndsum[doc_id]);
        for (int j = 0; j < K; j++){
            if (j != i){
                gau_prob[i] += exp(-2*eta[i]*eta[j]*nd[doc_id][j]/pow(ndsum[doc_id],2));
            }
        }
        gau_prob[i] += exp(-2*eta[i]*bias/ndsum[doc_id]);    // adding bias
        exp_sum += gau_prob[i];
    }
    for (int i = 0; i < K; i++){
        gau_prob[i] /= exp_sum;
    }*/

    // Method 2: sample based on the resudal of the origin rating
    double resudal_rate = 0.0;
    for (int i = 0; i < K; i++){
        rate = rate - eta[i]*nd[doc_id][i]/ndsum[doc_id];
    }
    resudal_rate = rate - bias;

    for (int i = 0; i < K; i++){
        gau_prob[i] = exp(-pow(resudal_rate-eta[i]/ndsum[doc_id], 2)/sigma);
        exp_sum += gau_prob[i];
    }
    
    for (int i = 0; i < K; i++){
        gau_prob[i] /= exp_sum;
    }
}

void model::tst_gau_prob(int doc_id, int wd_id){
    double exp_sum = 0.0;
    double rate = pnewdata->docs[doc_id]->rate;
    
    // Method 1: sample based on the origin rating
    /*for (int i = 0; i < K; i++){
        gau_prob[i] = exp((pow(eta[i],2)*(1+2*newnd[doc_id][i]))/pow(newndsum[doc_id],2)
                    - 2*rate*eta[i]/newndsum[doc_id]);
        for (int j = 0; j < K; j++){
            if (j != i){
 
                gau_prob[i] += exp(2*eta[i]*eta[j]*newnd[doc_id][j]/pow(newndsum[doc_id],2));
            }
        }
        gau_prob[i] += exp(2*eta[i]*bias/newndsum[doc_id]);    // adding bias
        exp_sum += gau_prob[i];
        
    }

    for (int i = 0; i < K; i++){
        gau_prob[i] /= exp_sum;
    }*/
    
    // Method 2: sample based on the resudal of the origin rating
    double resudal_rate = 0.0;
    for (int i = 0; i < K; i++){
        rate = rate - eta[i]*newnd[doc_id][i]/newndsum[doc_id];
    }
    resudal_rate = rate - bias;

    for (int i = 0; i < K; i++){
        gau_prob[i] = exp(-pow(resudal_rate-eta[i]/newndsum[doc_id], 2)/sigma);
        exp_sum += gau_prob[i];
    }
    
    for (int i = 0; i < K; i++){
        gau_prob[i] /= exp_sum;
    }
}

void model::pre_mle_learn(){
    // documents' ratings to vector
    char * temp_str = new char[128];
    string s1;
    tr_rate_str = "";
    for (int m = 0; m < M; m++){
        sprintf(temp_str, "%f", ptrndata->docs[m]->rate); 
        s1 = temp_str;
        if (m != M-1)
            s1 += ' ';
        tr_rate_str += s1;
    }
 
}

void model::mle_learn(){
    itpp::vec eta_vec, tr_rate_vec;
    itpp::mat tr_fea_mat;

    char * temp_str = new char[128];
    
    string s, s1;
    double ** tr_fea;

    tr_fea = compute_train_feature();
    eta_vec = eta_str;
    tr_rate_vec = tr_rate_str;
    // feature 2-d array to matrix
    for (int m = 0; m < M; m++){
        for (int k = 0; k < K; k++){
            sprintf(temp_str, "%f ", tr_fea[m][k]);
            s1 = temp_str;
            s += s1;
            memset(temp_str, 0, 128);
        }
        if (m != M - 1)
            s += "1;";  // for bias item
        else
            s += "1";
    }
    tr_fea_mat = s;
    
    //learning
    eta_vec = itpp::inv(sigma*itpp::eye(K+1)+tr_fea_mat.transpose()*tr_fea_mat)
        * tr_fea_mat.transpose() * tr_rate_vec;
    
    // update eta parameters
    double weight_diff = 0.0;
    for (int k = 0; k < K; k++){
        weight_diff += fabs(eta_vec(k)-eta[k]);
        eta[k] = eta_vec(k);
        cout << eta[k] << ' ';
    }
    cout << "Weight diff: " << weight_diff << endl;
    bias = eta_vec(K);
}

void model::save_eta(string eta_file){
    FILE * fout = fopen(eta_file.c_str(), "w");
    
    if (!fout) {
	    printf("Cannot open file %s to save!\n", eta_file.c_str());
        return ;
    }

    for (int k = 0; k < K; k++) {    
	    fprintf(fout, "%f\n", eta[k]);
    }
    fprintf(fout, "%f\n", bias);
    fclose(fout);
}

void model::read_eta(string eta_file){
    FILE * fin = fopen(eta_file.c_str(), "r");
    
    if (!fin) {
	    printf("Cannot open file %s to save!\n", eta_file.c_str());
	    return ;
    }

    eta = new double[K];
    for (int k = 0; k < K; k++)
        eta[k] = 0.0;

    char * buff = new char[128];
    for (int k = 0; k < K; k++) {    
	    fgets(buff, 128, fin);
        eta[k] = atof(buff);
        printf("%f\n", eta[k]);
        memset(buff, 0, 129);
    }
    fscanf(fin, "%f\n", &bias);
    fclose(fin);
}

